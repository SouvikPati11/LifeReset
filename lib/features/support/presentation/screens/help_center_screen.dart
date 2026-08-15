import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../providers/support_providers.dart';
import 'contact_support_screen.dart';
import 'faq_screen.dart';
import 'terms_screen.dart';

/// Help Center — a content-driven hub: an admin-managed intro plus quick links
/// to FAQs, Contact Support and the Terms of Service.
class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intro = ref.watch(helpContentProvider).valueOrNull;

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Help Center',
              subtitle: 'Find answers and get support',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      gradient: HomeStyle.scoreGradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      boxShadow: HomeStyle.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (intro != null && intro.title.trim().isNotEmpty)
                              ? intro.title
                              : 'How can we help?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          (intro != null && intro.body.trim().isNotEmpty)
                              ? intro.body
                              : 'Browse common questions or reach out to our '
                                  'support team — we usually reply within a day.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const LsGroupLabel('Browse'),
                  LsGroup(
                    children: [
                      LsRow(
                        icon: Icons.quiz_rounded,
                        title: 'FAQs',
                        subtitle: 'Answers to common questions',
                        onTap: () => _open(context, const FaqScreen()),
                      ),
                      LsRow(
                        icon: Icons.support_agent_rounded,
                        title: 'Contact Support',
                        subtitle: 'Get in touch with our team',
                        onTap: () =>
                            _open(context, const ContactSupportScreen()),
                      ),
                      LsRow(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms',
                        onTap: () => _open(context, const TermsScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
