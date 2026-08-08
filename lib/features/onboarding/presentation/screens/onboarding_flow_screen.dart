import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../steps/ai_analysis_step.dart';
import '../steps/breakup_timing_step.dart';
import '../steps/choose_problem_step.dart';
import '../steps/goal_step.dart';
import '../steps/hurt_most_step.dart';
import '../steps/personalized_plan_step.dart';
import '../steps/subscription_step.dart';
import '../steps/welcome_step.dart';
import '../widgets/onboarding_style.dart';

/// Hosts the full onboarding wizard as a single, button-driven [PageView].
///
/// A top-left back arrow (on every screen after Welcome) and a bottom page-dot
/// indicator are shared chrome, matching the Figma. Only one route
/// (`/onboarding`) is registered — steps are pages.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  // Page indices.
  static const int _welcome = 0;
  static const int _q3 = 4;
  static const int _analysis = 5;
  static const int _plan = 6;
  static const int _subscription = 7;

  // The Figma page-dots track the six answer/result steps (Q1 … subscription);
  // the welcome / choose-problem intro screens sit on the first dot.
  static const int _dotCount = 6;

  final PageController _pageController = PageController();
  Timer? _analysisTimer;
  int _index = 0;

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _next() => _goTo(_index + 1);

  void _back() {
    _analysisTimer?.cancel();
    // Skip the analysis screen when stepping back from the plan / analysis.
    final target = switch (_index) {
      _subscription => _plan,
      _plan => _q3,
      _analysis => _q3,
      _ => _index - 1,
    };
    if (target >= 0) _goTo(target);
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    if (index == _analysis) {
      _analysisTimer?.cancel();
      _analysisTimer = Timer(const Duration(milliseconds: 2600), () {
        if (mounted && _index == _analysis) _goTo(_plan);
      });
    }
  }

  bool get _showBack => _index != _welcome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingStyle.pageBottom,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: OnboardingStyle.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: _showBack
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppSizes.sm),
                          child: IconButton(
                            onPressed: _back,
                            iconSize: AppSizes.iconMd,
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: OnboardingStyle.ink),
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: [
                    WelcomeStep(onGetStarted: _next),
                    ChooseProblemStep(onContinue: _next),
                    BreakupTimingStep(onContinue: _next),
                    HurtMostStep(onContinue: _next),
                    GoalStep(onContinue: _next),
                    const AiAnalysisStep(),
                    PersonalizedPlanStep(onContinue: _next),
                    const SubscriptionStep(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                child: OnboardingDots(
                  count: _dotCount,
                  current: (_index - 2).clamp(0, _dotCount - 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
