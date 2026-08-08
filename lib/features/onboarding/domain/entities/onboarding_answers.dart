/// The recovery area a user is onboarding into (screen 2 — "What brings you
/// here today?").
enum OnboardingProblem {
  breakupRecovery('breakup_recovery', 'Breakup Recovery',
      'Heal from heartbreak and move forward'),
  anxietyStress(
      'anxiety_stress', 'Anxiety & Stress', 'Manage stress and find inner calm'),
  lowConfidence('low_confidence', 'Low Self-Confidence',
      'Build self-esteem and self worth'),
  overthinking(
      'overthinking', 'Overthinking', 'Clear your mind and think better');

  const OnboardingProblem(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;
}

/// Q1 — "When did your breakup happen?"
enum BreakupTiming {
  lessThan1Month(
      'less_than_1_month', 'Less than 1 month ago', "It's still fresh"),
  oneToThreeMonths(
      'one_to_three_months', '1 – 3 months ago', 'Still hard, but getting by'),
  threeToSixMonths(
      'three_to_six_months', '3 – 6 months ago', "I'm healing slowly"),
  moreThanSixMonths('more_than_six_months', 'More than 6 months ago',
      'I want to heal completely');

  const BreakupTiming(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;
}

/// Q2 — "What hurts you the most right now?"
enum HurtMost {
  missingThem('missing_them', 'Missing them', 'I miss their presence'),
  memories('memories', 'Memories', 'The memories hurt a lot'),
  loneliness('loneliness', 'Loneliness', 'I feel lonely and empty'),
  future('future', 'Future', "I'm scared about my future");

  const HurtMost(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;
}

/// Q3 — "What is your main goal right now?"
enum OnboardingGoal {
  moveOn('move_on', 'Move On', 'I want to let go and move on'),
  healFeelBetter(
      'heal_feel_better', 'Heal & Feel Better', 'I want to heal and feel better'),
  buildBetterMe('build_a_better_me', 'Build a Better Me',
      'I want to grow and become stronger'),
  getExBack('get_ex_back', 'Get My Ex Back', 'I want to win them back');

  const OnboardingGoal(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;
}

/// The complete set of answers captured during onboarding, ready to persist.
class OnboardingAnswers {
  const OnboardingAnswers({
    required this.problem,
    required this.breakupTiming,
    required this.hurtMost,
    required this.goal,
  });

  final OnboardingProblem problem;
  final BreakupTiming breakupTiming;
  final HurtMost hurtMost;
  final OnboardingGoal goal;
}
