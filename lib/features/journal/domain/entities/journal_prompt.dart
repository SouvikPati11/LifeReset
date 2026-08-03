/// A writing prompt (`journal_prompts/{id}`) to help users start an entry.
class JournalPrompt {
  const JournalPrompt({
    required this.id,
    required this.category,
    required this.text,
  });

  final String id;
  final String category;
  final String text;
}
