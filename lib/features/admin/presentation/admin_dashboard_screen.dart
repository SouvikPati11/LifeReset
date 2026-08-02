import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../authentication/presentation/controllers/auth_controller.dart';
import '../../authentication/presentation/providers/user_providers.dart';

/// Admin dashboard entry point.
///
/// Reached only when the signed-in user's server-side role resolves to
/// `admin`. This is the minimal, real admin surface the auth flow hands admins
/// to; the full admin tooling will be built out in the `admin` module.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text('Administrator', style: textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    profile?.email ?? '',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Text(
                    'You have administrator access. Admin tools will appear '
                    'here.',
                    style: textTheme.bodyLarge,
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
