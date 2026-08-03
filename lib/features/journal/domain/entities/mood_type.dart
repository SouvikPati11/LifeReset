/// The set of moods a user can record.
///
/// [score] is a 0–10 wellbeing value used for averages and trend charts; higher
/// is better. Colors are assigned in the UI layer to keep this framework-free.
enum MoodType {
  awful('awful', 'Awful', '😣', 1),
  sad('sad', 'Sad', '😢', 3),
  anxious('anxious', 'Anxious', '😰', 4),
  okay('okay', 'Okay', '😐', 6),
  good('good', 'Good', '🙂', 8),
  great('great', 'Great', '😄', 10);

  const MoodType(this.value, this.label, this.emoji, this.score);

  final String value;
  final String label;
  final String emoji;
  final int score;

  static MoodType fromValue(String? value) {
    return MoodType.values.firstWhere(
      (m) => m.value == value,
      orElse: () => MoodType.okay,
    );
  }

  /// The five moods shown in the journal composer (Awful → Great).
  static const List<MoodType> journalScale = [
    MoodType.awful,
    MoodType.sad,
    MoodType.okay,
    MoodType.good,
    MoodType.great,
  ];
}
