import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/journal_prompt.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_widgets.dart';
import 'new_journal_screen.dart';

/// Writing prompts grouped by category; tap one to start an entry from it.
class PromptsScreen extends ConsumerWidget {
  const PromptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(promptsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Journal Prompts')),
      body: SafeArea(
        child: promptsAsync.when(
          loading: () => const LoadingView(),
          error: (_, __) => ErrorView(
            title: 'Could not load prompts',
            onRetry: () => ref.invalidate(promptsProvider),
          ),
          data: (prompts) {
            if (prompts.isEmpty) {
              return const EmptyView(
                title: 'No prompts yet',
                message: 'Writing prompts will appear here soon.',
                icon: Icons.lightbulb_outline_rounded,
              );
            }
            final byCategory = <String, List<JournalPrompt>>{};
            for (final p in prompts) {
              byCategory.putIfAbsent(p.category, () => []).add(p);
            }
            final categories = byCategory.keys.toList()..sort();

            return ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                for (final category in categories) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final prompt in byCategory[category]!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: JCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                NewJournalScreen(initialText: prompt.text),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                prompt.text,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
