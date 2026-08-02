import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../authentication/presentation/controllers/auth_controller.dart';
import '../../authentication/presentation/providers/user_providers.dart';

/// User app entry point (post-authentication landing).
///
/// This is the minimal, real home surface the auth flow hands verified users
/// to — it shows the signed-in account from Firestore and offers sign-out. The
/// full Breakup Recovery experience will be built out in the `home` module.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeReset'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ContentContainer(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: profileAsync.when(
            loading: () => const LoadingView(),
            error: (_, __) => Center(
              child: Text(
                'Could not load your profile.',
                style: textTheme.bodyMedium,
              ),
            ),
            data: (profile) {
              final name = (profile?.name.isNotEmpty ?? false)
                  ? profile!.name
                  : 'there';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),
                  Text('Hi $name 👋', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Welcome to your recovery space.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  if (profile != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(label: 'Email', value: profile.email),
                            _InfoRow(
                              label: 'Plan',
                              value: profile.subscription.value,
                            ),
                            _InfoRow(label: 'Role', value: profile.role.value),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
