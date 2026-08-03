/// The result of asking the AI Coach for a reply (via the Cloud Function).
class CoachReply {
  const CoachReply({
    required this.text,
    required this.isCrisis,
    this.remaining,
  });

  final String text;

  /// True when the message triggered the crisis-safety path (a fixed support
  /// message returned instead of a generated reply).
  final bool isCrisis;

  /// Messages remaining today after this reply, or `null` when unlimited.
  final int? remaining;
}
