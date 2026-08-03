import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/journal_entry.dart';
import '../controllers/journal_editor_controller.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_widgets.dart';
import '../widgets/mood_widgets.dart';
import 'new_journal_screen.dart';

/// Read a single journal entry, with its AI Coach insight and edit/delete.
class JournalEntryDetailScreen extends ConsumerWidget {
  const JournalEntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok =
        await ref.read(journalEditorControllerProvider.notifier).delete(entryId);
    if (ok && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(entryDetailProvider(entryId));

    return Scaffold(
      appBar: AppBar(title: const Text('Journal Entry')),
      body: SafeArea(
        child: entryAsync.when(
          loading: () => const LoadingView(),
          error: (_, __) => const Center(child: Text('Could not load entry')),
          data: (entry) {
            if (entry == null) {
              return const Center(child: Text('Entry not found'));
            }
            return _Body(
              entry: entry,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewJournalScreen(entry: entry),
                ),
              ),
              onDelete: () => _delete(context, ref),
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final mood = entry.mood;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: AppSizes.iconSm, color: colorScheme.primary),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                DateFormat('MMMM d, yyyy • EEEE • h:mm a').format(entry.createdAt),
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            if (mood != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: moodColor(mood).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text('${mood.emoji} ${mood.label}',
                    style: textTheme.labelSmall),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          entry.title.isEmpty ? 'Untitled' : entry.title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSizes.md),
        if (entry.content.isNotEmpty)
          Text(entry.content, style: textTheme.bodyLarge?.copyWith(height: 1.5)),
        if (entry.tags.isNotEmpty) ...[
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [for (final t in entry.tags) TagChip(label: '#$t')],
          ),
        ],
        const SizedBox(height: AppSizes.lg),
        _InsightCard(insight: entry.aiInsight),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _share(context),
                icon: const Icon(Icons.share_outlined, size: AppSizes.iconSm),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: AppSizes.iconSm),
                label: const Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _share(BuildContext context) {
    final text = [entry.title, entry.content].where((s) => s.isNotEmpty).join('\n\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Entry copied to clipboard')));
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final String? insight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: AppSizes.iconSm, color: colorScheme.primary),
              const SizedBox(width: AppSizes.sm),
              Text('AI Coach Insight', style: textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (insight == null || insight!.isEmpty)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSizes.sm),
                Text('Generating your insight…', style: textTheme.bodySmall),
              ],
            )
          else
            Text(insight!, style: textTheme.bodyMedium?.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}
