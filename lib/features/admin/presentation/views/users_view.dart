import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../widgets/admin_forms.dart';
import '../widgets/admin_widgets.dart';

class UsersView extends ConsumerStatefulWidget {
  const UsersView({super.key});
  @override
  ConsumerState<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends ConsumerState<UsersView> {
  final _scroll = ScrollController();
  String _query = '';
  String _filter = 'All';
  static const _filters = ['All', 'Active', 'Suspended', 'Premium', 'Free'];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        ref.read(adminUsersControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _matches(AdminUser u) {
    final q = _query.toLowerCase();
    final okQuery = q.isEmpty ||
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q);
    final okFilter = switch (_filter) {
      'Active' => u.status == UserStatus.active,
      'Suspended' => u.status == UserStatus.suspended,
      'Premium' => u.plan == 'premium',
      'Free' => u.plan == 'free',
      _ => true,
    };
    return okQuery && okFilter;
  }

  Future<void> _setStatus(AdminUser u, UserStatus status) async {
    await ref
        .read(adminWriteControllerProvider.notifier)
        .save('users', u.uid, {'status': status.value});
    ref.invalidate(adminUsersControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminUsersControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const LoadingView(),
      error: (_, __) => ErrorView(
        title: 'Could not load users',
        onRetry: () => ref.invalidate(adminUsersControllerProvider),
      ),
      data: (state) {
        final users = state.users.where(_matches).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search users…',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final f in _filters)
                          Padding(
                            padding: const EdgeInsets.only(right: AppSizes.sm),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: _filter == f,
                              onSelected: (_) => setState(() => _filter = f),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: users.length + (state.loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  if (i >= users.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final u = users[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        (u.name.isEmpty ? '?' : u.name[0]).toUpperCase(),
                      ),
                    ),
                    title: Text(u.name.isEmpty ? u.email : u.name),
                    subtitle: Text(
                      '${u.email}\n${u.plan} · ${u.role} · '
                      '${u.createdAt == null ? '' : DateFormat('MMM d, yyyy').format(u.createdAt!)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusChip(
                          label: u.status.label,
                          color: switch (u.status) {
                            UserStatus.active => const Color(0xFF2E9E63),
                            UserStatus.suspended => const Color(0xFFE0A800),
                            UserStatus.deleted => colorScheme.error,
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            switch (v) {
                              case 'edit':
                                showUserEditDialog(context, u);
                              case 'suspend':
                                _setStatus(u, UserStatus.suspended);
                              case 'reactivate':
                                _setStatus(u, UserStatus.active);
                              case 'delete':
                                _setStatus(u, UserStatus.deleted);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'suspend', child: Text('Suspend')),
                            PopupMenuItem(
                                value: 'reactivate', child: Text('Reactivate')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
