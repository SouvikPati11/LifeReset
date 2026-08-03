import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_forms.dart';
import '../widgets/admin_widgets.dart';

class PromptsView extends ConsumerStatefulWidget {
  const PromptsView({super.key});
  @override
  ConsumerState<PromptsView> createState() => _PromptsViewState();
}

class _PromptsViewState extends ConsumerState<PromptsView> {
  String _query = '';
  PromptCategory? _category;

  bool _matches(PromptItem p) {
    final okQuery =
        _query.isEmpty || p.text.toLowerCase().contains(_query.toLowerCase());
    final okCat = _category == null || p.category == _category;
    return okQuery && okCat;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(promptsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Text('Journal Prompts', style: textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => showPromptForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Prompt'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search prompts…',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.sm),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                    ),
                    for (final c in PromptCategory.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.sm),
                        child: ChoiceChip(
                          label: Text(c.label),
                          selected: _category == c,
                          onSelected: (_) => setState(() => _category = c),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: async.when(
            loading: () => const LoadingView(),
            error: (_, __) => const Center(child: Text('Could not load')),
            data: (prompts) {
              final list = prompts.where(_matches).toList();
              if (list.isEmpty) {
                return const Center(child: Text('No prompts found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final p = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ACard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.text, style: textTheme.bodyMedium),
                                const SizedBox(height: AppSizes.xs),
                                Row(
                                  children: [
                                    StatusChip(
                                      label: p.category.label,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    StatusChip(
                                      label: p.status.label,
                                      color: p.status.isActive
                                          ? const Color(0xFF2E9E63)
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                showPromptForm(context, existing: p);
                              } else if (v == 'delete') {
                                if (await confirmDelete(context)) {
                                  await ref
                                      .read(adminWriteControllerProvider
                                          .notifier)
                                      .remove('journal_prompts', p.id);
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
