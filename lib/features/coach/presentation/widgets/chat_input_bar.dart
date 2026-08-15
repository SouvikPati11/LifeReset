import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';

/// The chat composer: a rounded message field with a purple send button and a
/// compact quick-action row (Journal / Mood / Task). The send button reflects
/// enabled / disabled / sending states.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onQuickAction,
    this.enabled = true,
    this.sending = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onQuickAction;
  final bool enabled;
  final bool sending;

  static const List<(String, IconData)> _quick = [
    ('Journal', Icons.menu_book_rounded),
    ('Mood', Icons.mood_rounded),
    ('Task', Icons.checklist_rounded),
  ];

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _submit() {
    final text = widget.controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final canSend = widget.enabled && hasText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSizes.sm,
          runSpacing: AppSizes.xs,
          children: [
            for (final (label, icon) in ChatInputBar._quick)
              _QuickChip(
                label: label,
                icon: icon,
                onTap: widget.enabled ? () => widget.onQuickAction(label) : null,
              ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.enabled ? HomeStyle.card : HomeStyle.lavenderLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: HomeStyle.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 14.5, color: HomeStyle.ink),
                  cursorColor: HomeStyle.primary,
                  decoration: const InputDecoration(
                    isDense: true,
                    // The white pill container is the background; never let the
                    // global filled InputDecorationTheme paint over it.
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Message AI Coach…',
                    hintStyle: TextStyle(color: HomeStyle.inkSoft, fontSize: 14.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            _SendButton(
              enabled: canSend,
              sending: widget.sending,
              onTap: _submit,
            ),
          ],
        ),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.sending,
    required this.onTap,
  });

  final bool enabled;
  final bool sending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled || sending ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled || sending ? HomeStyle.scoreGradient : null,
          color: enabled || sending ? null : HomeStyle.lavender,
          shape: BoxShape.circle,
          boxShadow: enabled ? HomeStyle.softShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: SizedBox(
              width: 48,
              height: 48,
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      color: enabled ? Colors.white : HomeStyle.primary,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: HomeStyle.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: HomeStyle.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
