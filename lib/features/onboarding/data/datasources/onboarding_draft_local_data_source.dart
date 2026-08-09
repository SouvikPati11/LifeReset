import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/onboarding_answers.dart';

/// A partially-filled set of onboarding answers, persisted locally so an app
/// restart mid-flow doesn't lose the user's progress.
class OnboardingDraft {
  const OnboardingDraft({
    this.problem,
    this.breakupTiming,
    this.hurtMost,
    this.goal,
  });

  final OnboardingProblem? problem;
  final BreakupTiming? breakupTiming;
  final HurtMost? hurtMost;
  final OnboardingGoal? goal;

  bool get isEmpty =>
      problem == null &&
      breakupTiming == null &&
      hurtMost == null &&
      goal == null;
}

/// Stores the in-progress onboarding draft in SharedPreferences, scoped per
/// user so drafts never leak between accounts.
///
/// Every method is best-effort: a persistence failure (or a missing plugin in
/// tests) is swallowed and never surfaces to the onboarding flow.
class OnboardingDraftLocalDataSource {
  const OnboardingDraftLocalDataSource();

  static String _key(String uid) => 'onboarding_draft_v1_$uid';

  Future<void> save(String uid, OnboardingDraft draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key(uid),
        jsonEncode({
          'problem': draft.problem?.value,
          'breakupTiming': draft.breakupTiming?.value,
          'hurtMost': draft.hurtMost?.value,
          'goal': draft.goal?.value,
        }),
      );
    } catch (_) {
      // Best-effort: a failed draft save must never break onboarding.
    }
  }

  Future<OnboardingDraft?> load(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(uid));
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return OnboardingDraft(
        problem: _problem(map['problem'] as String?),
        breakupTiming: _timing(map['breakupTiming'] as String?),
        hurtMost: _hurt(map['hurtMost'] as String?),
        goal: _goal(map['goal'] as String?),
      );
    } catch (_) {
      // A corrupt or unreadable draft is treated as no draft.
      return null;
    }
  }

  Future<void> clear(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(uid));
    } catch (_) {
      // Best-effort.
    }
  }

  OnboardingProblem? _problem(String? v) {
    for (final e in OnboardingProblem.values) {
      if (e.value == v) return e;
    }
    return null;
  }

  BreakupTiming? _timing(String? v) {
    for (final e in BreakupTiming.values) {
      if (e.value == v) return e;
    }
    return null;
  }

  HurtMost? _hurt(String? v) {
    for (final e in HurtMost.values) {
      if (e.value == v) return e;
    }
    return null;
  }

  OnboardingGoal? _goal(String? v) {
    for (final e in OnboardingGoal.values) {
      if (e.value == v) return e;
    }
    return null;
  }
}
