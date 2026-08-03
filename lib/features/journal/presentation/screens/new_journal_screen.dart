import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/mood_type.dart';
import '../controllers/journal_editor_controller.dart';
import '../widgets/journal_widgets.dart';
import '../widgets/mood_widgets.dart';
import 'journal_entry_detail_screen.dart';

/// Compose a new journal entry, or edit an existing one.
class NewJournalScreen extends ConsumerStatefulWidget {
  const NewJournalScreen({super.key, this.entry, this.initialText});

  final JournalEntry? entry;
  final String? initialText;

  bool get isEditing => entry != null;

  @override
  ConsumerState<NewJournalScreen> createState() => _NewJournalScreenState();
}

class _NewJournalScreenState extends ConsumerState<NewJournalScreen> {
  static const int _maxChars = 1000;
  static const List<String> _suggestedTags = [
    'breakup',
    'lonely',
    'anxiety',
    'progress',
    'hopeful',
  ];

  late final TextEditingController _text;
  MoodType? _mood;
  late Set<String> _tags;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    final initial = entry != null
        ? [entry.title, entry.content].where((s) => s.isNotEmpty).join('\n')
        : (widget.initialText ?? '');
    _text = TextEditingController(text: initial);
    _mood = entry?.mood;
    _tags = {...?entry?.tags};
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  ({String title, String content}) _split(String raw) {
    final lines = raw.trim().split('\n');
    final title = lines.first.trim();
    final content =
        lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';
    return (title: title, content: content);
  }

  Future<void> _save() async {
    final raw = _text.text.trim();
    if (raw.isEmpty) return;
    final parts = _split(raw);
    final controller = ref.read(journalEditorControllerProvider.notifier);
    final tags = _tags.toList();

    if (widget.isEditing) {
      final ok = await controller.updateEntry(
        entryId: widget.entry!.id,
        title: parts.title,
        content: parts.content,
        mood: _mood,
        tags: tags,
      );
      if (ok && mounted) Navigator.of(context).pop();
    } else {
      final id = await controller.create(
        title: parts.title,
        content: parts.content,
        mood: _mood,
        tags: tags,
      );
      if (id != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => JournalEntryDetailScreen(entryId: id),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalEditorControllerProvider);
    final isSaving = state.isLoading;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final charCount = _text.text.length;

    ref.listen(journalEditorControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text((next.error as Failure).message),
          ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Journal' : 'New Journal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text('Write freely...', style: textTheme.titleMedium),
            Text(
              'This is your safe space. Be honest with yourself.',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.lg),
            Text('How are you feeling now?', style: textTheme.titleSmall),
            const SizedBox(height: AppSizes.sm),
            MoodSelectorRow(
              moods: MoodType.journalScale,
              selected: _mood,
              onSelect: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: AppSizes.lg),
            TextField(
              controller: _text,
              maxLines: 8,
              maxLength: _maxChars,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Today was...',
                alignLabelWithHint: true,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$charCount/$_maxChars',
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Add Tags (Optional)', style: textTheme.titleSmall),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                for (final tag in _suggestedTags)
                  TagChip(
                    label: '#$tag',
                    selected: _tags.contains(tag),
                    onTap: () => setState(() {
                      _tags.contains(tag) ? _tags.remove(tag) : _tags.add(tag);
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
