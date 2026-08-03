import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_forms.dart';
import '../widgets/admin_widgets.dart';

class DailyTasksView extends ConsumerStatefulWidget {
  const DailyTasksView({super.key});
  @override
  ConsumerState<DailyTasksView> createState() => _DailyTasksViewState();
}

class _DailyTasksViewState extends ConsumerState<DailyTasksView> {
  String? _programId;

  Future<void> _onReorder(List<ProgramTaskItem> tasks, int oldIndex, int newIndex) async {
    final list = [...tasks];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    final c = ref.read(adminWriteControllerProvider.notifier);
    for (var i = 0; i < list.length; i++) {
      await c.save('program_tasks', list[i].id, {'order': i});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final programs = ref.watch(programsProvider).valueOrNull ?? const [];
    _programId ??= programs.isNotEmpty ? programs.first.id : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Text('Daily Tasks', style: textTheme.titleLarge),
              const Spacer(),
              if (_programId != null)
                FilledButton.icon(
                  onPressed: () => showTaskForm(context, _programId!),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Task'),
                ),
            ],
          ),
        ),
        if (programs.isEmpty)
          const Expanded(
            child: Center(child: Text('Create a program first.')),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: DropdownButtonFormField<String>(
              value: _programId,
              decoration: const InputDecoration(labelText: 'Program'),
              items: [
                for (final p in programs)
                  DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: (v) => setState(() => _programId = v),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Expanded(child: _TaskList(programId: _programId!, onReorder: _onReorder)),
        ],
      ],
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.programId, required this.onReorder});
  final String programId;
  final Future<void> Function(List<ProgramTaskItem>, int, int) onReorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(programTasksProvider(programId));
    final textTheme = Theme.of(context).textTheme;

    return async.when(
      loading: () => const LoadingView(),
      error: (_, __) => const Center(child: Text('Could not load')),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks yet. Add one.'));
        }
        return ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          itemCount: tasks.length,
          onReorder: (o, n) => onReorder(tasks, o, n),
          itemBuilder: (context, i) {
            final t = tasks[i];
            return Padding(
              key: ValueKey(t.id),
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: ACard(
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator_rounded, size: 20),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Day ${t.day} · ${t.task}',
                              style: textTheme.titleSmall),
                          if (t.estimatedMinutes > 0)
                            Text('${t.estimatedMinutes} min',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: t.status.label,
                      color: t.status.isActive
                          ? const Color(0xFF2E9E63)
                          : Theme.of(context).colorScheme.outline,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          showTaskForm(context, programId, existing: t);
                        } else if (v == 'delete') {
                          if (await confirmDelete(context)) {
                            await ref
                                .read(adminWriteControllerProvider.notifier)
                                .remove('program_tasks', t.id);
                          }
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
