import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/content_keys.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

/// Admin editor for long-form content pages shown in the app: Terms of Service
/// and the Help Center intro. Each is stored as a single `app_config` document
/// ({title, body}) and edited through the shared admin write controller.
class ContentPagesView extends ConsumerWidget {
  const ContentPagesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text('Content Pages', style: textTheme.titleLarge),
        const SizedBox(height: AppSizes.xs),
        Text(
          'Edit the Terms of Service and Help Center content shown in the app.',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        const _PageCard(
          docId: ContentPaths.termsDoc,
          heading: 'Terms of Service',
          defaultTitle: 'Terms of Service',
        ),
        const SizedBox(height: AppSizes.md),
        const _PageCard(
          docId: ContentPaths.helpDoc,
          heading: 'Help Center',
          defaultTitle: 'Help Center',
        ),
      ],
    );
  }
}

class _PageCard extends ConsumerWidget {
  const _PageCard({
    required this.docId,
    required this.heading,
    required this.defaultTitle,
  });

  final String docId;
  final String heading;
  final String defaultTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(contentPageProvider(docId));
    return async.when(
      loading: () => const ACard(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: LoadingView(),
        ),
      ),
      error: (_, __) => ACard(
        child: Text('Could not load "$heading".'),
      ),
      data: (page) => _PageEditor(
        key: ValueKey('$docId-loaded'),
        docId: docId,
        heading: heading,
        page: page.title.isEmpty && page.body.isEmpty
            ? ContentPage(title: defaultTitle, body: page.body)
            : page,
      ),
    );
  }
}

class _PageEditor extends ConsumerStatefulWidget {
  const _PageEditor({
    super.key,
    required this.docId,
    required this.heading,
    required this.page,
  });

  final String docId;
  final String heading;
  final ContentPage page;

  @override
  ConsumerState<_PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends ConsumerState<_PageEditor> {
  late final _title = TextEditingController(text: widget.page.title);
  late final _body = TextEditingController(text: widget.page.body);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await ref.read(adminWriteControllerProvider.notifier).save(
      ContentPaths.appConfig,
      widget.docId,
      {
        ContentKeys.title: _title.text.trim(),
        ContentKeys.body: _body.text.trim(),
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '${widget.heading} saved' : 'Could not save')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(adminWriteControllerProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;
    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.heading, style: textTheme.titleMedium),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _body,
            minLines: 6,
            maxLines: 16,
            decoration: const InputDecoration(
              labelText: 'Content',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          FilledButton.icon(
            onPressed: saving ? null : _save,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text('Save ${widget.heading}'),
          ),
        ],
      ),
    );
  }
}
