import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_forms.dart';
import '../widgets/admin_widgets.dart';

class ProgramsView extends ConsumerWidget {
  const ProgramsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(programsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Text('Programs', style: textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => showProgramForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Program'),
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const LoadingView(),
            error: (_, __) => const Center(child: Text('Could not load')),
            data: (programs) {
              if (programs.isEmpty) {
                return const Center(child: Text('No programs yet. Add one.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: programs.length,
                itemBuilder: (context, i) {
                  final p = programs[i];
                  final color = hexColor(p.colorHex);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ACard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.15),
                            child: Icon(programIcon(p.iconKey), color: color),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: textTheme.titleSmall),
                                Text(
                                  '${p.totalDays} days · ${p.userCount} users',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            label: p.status.label,
                            color: p.status.isActive
                                ? const Color(0xFF2E9E63)
                                : Theme.of(context).colorScheme.outline,
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                showProgramForm(context, existing: p);
                              } else if (v == 'delete') {
                                if (await confirmDelete(context)) {
                                  await ref
                                      .read(adminWriteControllerProvider.notifier)
                                      .remove('programs', p.id);
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
