import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/coach/domain/entities/chat_message.dart';
import 'package:lifereset/features/coach/presentation/widgets/markdown_text.dart';
import 'package:lifereset/features/coach/presentation/widgets/message_bubble.dart';
import 'package:lifereset/features/home/presentation/widgets/home_style.dart';

ChatMessage _msg(String text, ChatSender sender) => ChatMessage(
      id: 't',
      conversationId: 'c',
      text: text,
      sender: sender,
      timestamp: DateTime(2026, 1, 1, 9),
    );

Widget _host(Widget child) => MaterialApp(
      // Even if the ambient theme were dark, the bubble must stay readable.
      theme: ThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('AI message renders with the intended ink colour (not black)',
      (t) async {
    await t.pumpWidget(_host(MessageBubble(message: _msg('Hello **there**', ChatSender.ai))));
    final md = t.widget<MarkdownText>(find.byType(MarkdownText));
    expect(md.style?.color, HomeStyle.ink);
    expect(md.style?.color, isNot(Colors.black));
  });

  testWidgets('User message keeps its white-on-purple styling', (t) async {
    await t.pumpWidget(_host(MessageBubble(message: _msg('Hi', ChatSender.user))));
    // User text is a plain Text (not markdown) in white.
    expect(find.byType(MarkdownText), findsNothing);
    final text = t.widget<Text>(find.text('Hi'));
    expect(text.style?.color, Colors.white);
  });

  testWidgets('MarkdownText spans inherit the supplied colour, incl. bold',
      (t) async {
    await t.pumpWidget(_host(const MarkdownText(
      data: 'plain **bold**',
      style: TextStyle(color: HomeStyle.ink, fontSize: 14),
    )));
    final richTexts = t.widgetList<RichText>(find.byType(RichText));
    final colors = <Color?>[];
    for (final rt in richTexts) {
      rt.text.visitChildren((span) {
        if (span is TextSpan) colors.add(span.style?.color);
        return true;
      });
    }
    // Every coloured span uses ink; none falls back to pure black.
    expect(colors.where((c) => c != null), isNotEmpty);
    expect(colors.where((c) => c != null).every((c) => c == HomeStyle.ink),
        isTrue);
  });

  testWidgets('MarkdownText with no style defaults to ink, never black',
      (t) async {
    await t.pumpWidget(_host(const MarkdownText(data: 'fallback text')));
    // The wrapping DefaultTextStyle carries ink.
    final def = t.widget<DefaultTextStyle>(
      find
          .descendant(
            of: find.byType(MarkdownText),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(def.style.color, HomeStyle.ink);
  });
}
