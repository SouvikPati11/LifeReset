/// The recovery program a user is onboarding into.
///
/// Version 1 only supports Breakup Recovery.
enum OnboardingProblem {
  breakupRecovery('breakup_recovery', 'Breakup Recovery');

  const OnboardingProblem(this.value, this.label);

  final String value;
  final String label;
}

/// Q1 — "When did your breakup happen?"
enum BreakupTiming {
  today('today', 'Today'),
  last7Days('last_7_days', 'Last 7 days'),
  lastMonth('last_month', 'Last Month'),
  moreThan3Months('more_than_3_months', 'More than 3 Months');

  const BreakupTiming(this.value, this.label);

  final String value;
  final String label;
}

/// Q2 — "What hurts the most?"
enum HurtMost {
  missThem('miss_them', 'I miss them', '🙁'),
  cantSleep('cant_sleep', "I can't sleep", '😴'),
  feelLonely('feel_lonely', 'I feel lonely', '🧍'),
  overthink('overthink', 'I overthink', '🧠'),
  wantThemBack('want_them_back', 'I want them back', '💚');

  const HurtMost(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;
}

/// Q3 — "What is your goal?"
enum OnboardingGoal {
  moveOn('move_on', 'Move On', '🍃'),
  stopThinking('stop_thinking', 'Stop Thinking', '🧠'),
  sleepBetter('sleep_better', 'Sleep Better', '🌙'),
  feelHappyAgain('feel_happy_again', 'Feel Happy Again', '🙂');

  const OnboardingGoal(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;
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
