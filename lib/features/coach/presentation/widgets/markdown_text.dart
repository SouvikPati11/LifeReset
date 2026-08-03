import 'package:flutter/material.dart';

/// A minimal Markdown renderer for AI messages.
///
/// Supports the subset the coach uses — paragraphs, blank-line spacing, bullet
/// lists (`- `, `* `, `• `) and inline bold (`**text**`) — without pulling in an
/// external package.
class MarkdownText extends StatelessWidget {
  const MarkdownText({super.key, required this.data, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium!;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
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
