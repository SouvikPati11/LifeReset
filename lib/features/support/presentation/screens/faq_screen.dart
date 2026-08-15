import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/support_content.dart';
import '../providers/support_providers.dart';

/// Frequently Asked Questions — an admin-managed, expandable accordion list.
class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(faqsProvider);
    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'FAQs',
              subtitle: 'Answers to common questions',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: async.when(
                loading: () => const LsLoader(),
                error: (_, __) => LsErrorState(
                  title: 'Could not load FAQs',
                  message: 'Please check your connection and try again.',
                  onRetry: () => ref.invalidate(faqsProvider),
                ),
                data: (faqs) {
                  if (faqs.isEmpty) {
                    return const LsEmpty(
                      icon: Icons.quiz_rounded,
                      title: 'No content is available yet.',
                      message:
                          'Helpful answers will appear here once published. '
                          'Reach out to support any time in the meantime.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                    itemCount: faqs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (context, i) => _FaqTile(faq: faqs[i]),
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

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.faq});

  final FaqEntry faq;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return LsCard(
      padding: EdgeInsets.zero,
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: HomeStyle.ink,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.expand_more_rounded,
                      color: HomeStyle.primary),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSizes.sm),
                child: Text(
                  widget.faq.answer,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: HomeStyle.inkSoft,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}
