import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

/// Manage administrator accounts using the existing binary user/admin role.
///
/// Admins can be searched, activated/deactivated, and have their access granted
/// or revoked. All changes go through the audited write controller and are
/// enforced server-side by Firestore rules; the acting admin can never remove
/// their own access here (avoiding accidental lock-out and self-tampering).
class AdminUsersView extends ConsumerStatefulWidget {
  const AdminUsersView({super.key});

  @override
  ConsumerState<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends ConsumerState<AdminUsersView> {
  String _query = '';

  bool _matches(AdminUser u) {
    final q = _query.toLowerCase();
    return q.isEmpty ||
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q);
  }

  Future<void> _setStatus(AdminUser u, UserStatus status) async {
    await ref
        .read(adminWriteControllerProvider.notifier)
        .save('users', u.uid, {'status': status.value});
  }

  Future<void> _setRole(AdminUser u, String role) async {
    await ref
        .read(adminWriteControllerProvider.notifier)
        .save('users', u.uid, {'role': role});
  }

  Future<void> _grantByEmail() async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Grant admin access'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'User email',
            hintText: 'name@example.com',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Grant'),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty || !mounted) return;

    final result =
        await ref.read(adminRepositoryProvider).findUserByEmail(email);
    if (!mounted) return;
    await result.when(
      success: (user) async {
        if (user == null) {
          _snack('No account found for $email');
          return;
        }
        if (user.role == 'admin') {
          _snack('${user.email} is already an admin.');
          return;
        }
        await _setRole(user, 'admin');
        if (mounted) _snack('Granted admin access to ${user.email}.');
      },
      failure: (f) async => _snack(f.message),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(adminUsersListProvider);
    final myUid = ref.watch(userProfileProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _grantByEmail,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Grant admin'),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, __) => ErrorView(
          title: 'Could not load admins',
          onRetry: () => ref.invalidate(adminUsersListProvider),
        ),
        data: (admins) {
          final list = admins.where(_matches).toList();
          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search admins…',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text('${admins.length} administrator${admins.length == 1 ? '' : 's'}',
                  style: textTheme.labelMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSizes.sm),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xl),
                  child: Center(
                    child: Text('No administrators found.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: HomeStyle.inkSoft)),
                  ),
                )
              else
                for (final u in list) ...[
                  _AdminRow(
                    user: u,
                    isSelf: u.uid == myUid,
                    onStatus: (s) => _setStatus(u, s),
                    onRevoke: () => _setRole(u, 'user'),
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
              const SizedBox(height: 72), // clearance for the FAB
            ],
          );
        },
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({
    required this.user,
    required this.isSelf,
    required this.onStatus,
    required this.onRevoke,
  });

  final AdminUser user;
  final bool isSelf;
  final ValueChanged<UserStatus> onStatus;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return ACard(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              (user.name.isEmpty ? user.email : user.name)[0].toUpperCase(),
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name.isEmpty ? user.email : user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 6),
                      const StatusChip(label: 'You', color: HomeStyle.primary),
                    ],
                  ],
                ),
                Text(user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          StatusChip(
            label: user.status.label,
            color: switch (user.status) {
              UserStatus.active => const Color(0xFF2E9E63),
              UserStatus.suspended => const Color(0xFFE0A800),
              UserStatus.deleted => colorScheme.error,
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'suspend':
                  onStatus(UserStatus.suspended);
                case 'reactivate':
                  onStatus(UserStatus.active);
                case 'revoke':
                  onRevoke();
              }
            },
            itemBuilder: (_) => [
              if (user.status != UserStatus.suspended)
                const PopupMenuItem(
                    value: 'suspend', child: Text('Deactivate')),
              if (user.status != UserStatus.active)
                const PopupMenuItem(
                    value: 'reactivate', child: Text('Activate')),
              // The acting admin can never revoke their own access.
              if (!isSelf)
                const PopupMenuItem(
                    value: 'revoke', child: Text('Revoke admin')),
            ],
          ),
        ],
      ),
    );
  }
}
