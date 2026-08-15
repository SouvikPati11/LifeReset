import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../providers/support_providers.dart';

/// Terms of Service — admin-managed long-form content.
class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(termsProvider);
    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Terms of Service',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: async.when(
                loading: () => const LsLoader(),
                error: (_, __) => LsErrorState(
                  title: 'Could not load the terms',
                  message: 'Please check your connection and try again.',
                  onRetry: () => ref.invalidate(termsProvider),
                ),
                data: (page) {
                  if (page.isEmpty) {
                    return const LsEmpty(
                      icon: Icons.description_rounded,
                      title: 'No content is available yet.',
                      message:
                          'Our Terms of Service will appear here once published.',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                    children: [
                      if (page.title.trim().isNotEmpty) ...[
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: HomeStyle.ink,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],
                      LsCard(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: SelectableText(
                          page.body,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.55,
                            color: Color(0xFF3B3B52),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
