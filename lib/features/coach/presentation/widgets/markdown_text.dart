import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/home_style.dart';

/// A minimal Markdown renderer for AI messages.
///
/// Supports the subset the coach uses — paragraphs, blank-line spacing, bullet
/// lists (`- `, `* `, `• `) and inline bold (`**text**`) — without pulling in an
/// external package.
///
/// The rendered text is wrapped in a [DefaultTextStyle] built from [style], so
/// every glyph (including inline spans) uses the intended readable colour and
/// can never fall back to the ambient near-black default.
class MarkdownText extends StatelessWidget {
  const MarkdownText({super.key, required this.data, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // Default to the app's primary ink colour (never a bare theme fallback that
    // could render pure black on the light bubble).
    final base = style ??
        const TextStyle(color: HomeStyle.ink, fontSize: 14.5, height: 1.45);
    final blocks = <Widget>[];

    for (final rawLine in data.split('\n')) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        blocks.add(const SizedBox(height: 6));
        continue;
      }
      final trimmed = line.trimLeft();
      final isBullet = trimmed.startsWith('- ') ||
          trimmed.startsWith('* ') ||
          trimmed.startsWith('• ');
      if (isBullet) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 2, left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: base),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: _inline(trimmed.substring(2), base)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text.rich(TextSpan(children: _inline(line, base))),
          ),
        );
      }
    }

    return DefaultTextStyle.merge(
      style: base,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks,
      ),
    );
  }

  List<TextSpan> _inline(String text, TextStyle base) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final bold = i.isOdd;
      spans.add(TextSpan(
        text: parts[i],
        style: bold ? base.copyWith(fontWeight: FontWeight.w700) : base,
      ));
    }
    return spans;
  }
}
