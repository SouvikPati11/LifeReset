import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// The chat composer: a message field with a send button and the quick
/// attachment row (Attach / Journal / Mood / Task) shown in the design.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onQuickAction,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onQuickAction;
  final bool enabled;

  static const List<(String, IconData)> _quick = [
    ('Attach', Icons.attach_file_rounded),
    ('Journal', Icons.menu_book_rounded),
    ('Mood', Icons.mood_rounded),
    ('Task', Icons.checklist_rounded),
  ];

  void _submit() {
    final text = controller.text.trim();
    if (text.isEmpty || !enabled) return;
    onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: 'Message AI Coach…',
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            IconButton.filled(
              onPressed: enabled ? _submit : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final (label, icon) in _quick)
              InkWell(
                onTap: () => onQuickAction(label),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: AppSizes.iconSm,
                          color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 2),
                      Text(label, style: textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
