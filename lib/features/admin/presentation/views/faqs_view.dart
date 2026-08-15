import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_forms.dart';
import '../widgets/admin_widgets.dart';

/// Admin management for Help Center FAQs (question / answer / order / status).
class FaqsView extends ConsumerStatefulWidget {
  const FaqsView({super.key});
  @override
  ConsumerState<FaqsView> createState() => _FaqsViewState();
}

class _FaqsViewState extends ConsumerState<FaqsView> {
  String _query = '';

  bool _matches(FaqItem f) {
    if (_query.isEmpty) return true;
    final needle = _query.toLowerCase();
    return f.question.toLowerCase().contains(needle) ||
        f.answer.toLowerCase().contains(needle);
  }

  Future<void> _toggleStatus(FaqItem f) async {
    final next =
        f.status.isActive ? ContentStatus.inactive : ContentStatus.active;
    await ref
        .read(adminWriteControllerProvider.notifier)
        .save('faqs', f.id, {'status': next.value});
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(faqsAdminProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Text('FAQs', style: textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => showFaqForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add FAQ'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search FAQs…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: async.when(
            loading: () => const LoadingView(),
            error: (_, __) => const Center(child: Text('Could not load')),
            data: (faqs) {
              final list = faqs.where(_matches).toList();
              if (list.isEmpty) {
                return const Center(child: Text('No FAQs yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final f = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ACard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Text('${f.order}',
                                style: textTheme.labelSmall),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.question,
                                    style: textTheme.titleSmall),
                                const SizedBox(height: AppSizes.xs),
                                Text(
                                  f.answer,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          StatusChip(
                            label: f.status.label,
                            color: f.status.isActive
                                ? const Color(0xFF2E9E63)
                                : Theme.of(context).colorScheme.outline,
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              switch (v) {
                                case 'edit':
                                  showFaqForm(context, existing: f);
                                case 'toggle':
                                  await _toggleStatus(f);
                                case 'delete':
                                  if (await confirmDelete(context)) {
                                    await ref
                                        .read(adminWriteControllerProvider
                                            .notifier)
                                        .remove('faqs', f.id);
                                  }
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Text(f.status.isActive
                                    ? 'Deactivate'
                                    : 'Activate'),
                              ),
                              const PopupMenuItem(
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
