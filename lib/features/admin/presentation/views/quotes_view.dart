import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_forms.dart';
import '../widgets/admin_widgets.dart';

class QuotesView extends ConsumerStatefulWidget {
  const QuotesView({super.key});
  @override
  ConsumerState<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends ConsumerState<QuotesView> {
  String _query = '';

  bool _matches(QuoteItem q) {
    if (_query.isEmpty) return true;
    final needle = _query.toLowerCase();
    return q.text.toLowerCase().contains(needle) ||
        q.author.toLowerCase().contains(needle);
  }

  Future<void> _toggleStatus(QuoteItem q) async {
    final next = q.status.isActive ? ContentStatus.inactive : ContentStatus.active;
    await ref
        .read(adminWriteControllerProvider.notifier)
        .save('quotes', q.id, {'status': next.value});
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(quotesProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Text('Daily Quotes', style: textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => showQuoteForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Quote'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search quotes…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: async.when(
            loading: () => const LoadingView(),
            error: (_, __) => const Center(child: Text('Could not load')),
            data: (quotes) {
              final list = quotes.where(_matches).toList();
              if (list.isEmpty) {
                return const Center(child: Text('No quotes found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final q = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ACard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('“${q.text}”',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    )),
                                const SizedBox(height: AppSizes.xs),
                                Text(
                                  q.author.isEmpty
                                      ? q.category
                                      : '— ${q.author} · ${q.category}',
                                  style: textTheme.labelSmall?.copyWith(
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
                            label: q.status.label,
                            color: q.status.isActive
                                ? const Color(0xFF2E9E63)
                                : Theme.of(context).colorScheme.outline,
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              switch (v) {
                                case 'edit':
                                  showQuoteForm(context, existing: q);
                                case 'toggle':
                                  await _toggleStatus(q);
                                case 'delete':
                                  if (await confirmDelete(context)) {
                                    await ref
                                        .read(adminWriteControllerProvider
                                            .notifier)
                                        .remove('quotes', q.id);
                                  }
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Text(q.status.isActive
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
