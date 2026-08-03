import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/mood_type.dart';
import '../controllers/mood_check_controller.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_widgets.dart';
import '../widgets/mood_widgets.dart';

/// Record (or update) today's mood, with optional factors and a note.
class MoodCheckScreen extends ConsumerStatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  ConsumerState<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends ConsumerState<MoodCheckScreen> {
  static const List<String> _factors = [
    'Missing Ex',
    'Lonely',
    'Overthinking',
    'Anxiety',
    'Work/Study',
    'Family',
    'Sleep',
    'Other',
  ];

  final _note = TextEditingController();
  MoodType? _mood;
  final Set<String> _selectedFactors = {};
  var _prefilled = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mood = _mood;
    if (mood == null) return;
    final ok = await ref.read(moodCheckControllerProvider.notifier).save(
          mood: mood,
          note: _note.text.trim(),
          factors: _selectedFactors.toList(),
        );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final saving = ref.watch(moodCheckControllerProvider).isLoading;

    // Prefill from today's mood (if already recorded) once.
    final today = ref.watch(todayMoodProvider).valueOrNull;
    if (!_prefilled && today != null) {
      _prefilled = true;
      _mood = today.mood;
      _selectedFactors.addAll(today.factors);
      if (today.note.isNotEmpty) _note.text = today.note;
    }

    ref.listen(moodCheckControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text((next.error as Failure).message)),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Check')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.eco_rounded, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'How are you feeling today?',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Choose the mood that best describes your current state',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.lg),
            MoodSelectorGrid(
              selected: _mood,
              onSelect: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: AppSizes.lg),
            Text("What's affecting your mood?", style: textTheme.titleSmall),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                for (final f in _factors)
                  TagChip(
                    label: f,
                    selected: _selectedFactors.contains(f),
                    onTap: () => setState(() {
                      _selectedFactors.contains(f)
                          ? _selectedFactors.remove(f)
                          : _selectedFactors.add(f);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)…',
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            PrimaryButton(
              label: 'Save Mood',
              isLoading: saving,
              onPressed: _mood == null ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
