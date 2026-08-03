/// A motivational quote for the day (`quotes/{yyyy-MM-dd}`).
class DailyQuote {
  const DailyQuote({required this.text, required this.author});

  final String text;
  final String author;

  /// Fallback shown when today's quote has not been published yet.
  static const DailyQuote fallback = DailyQuote(
    text:
        'Healing doesn’t mean the damage never existed. It means the damage no '
        'longer controls your life.',
    author: 'Unknown',
  );
}
