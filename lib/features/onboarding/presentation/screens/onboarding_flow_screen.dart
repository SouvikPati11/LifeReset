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
import '../widgets/onboarding_progress_bar.dart';

/// Hosts the full onboarding wizard as a single, button-driven [PageView].
///
/// The top chrome (progress bar + back button) is shared across the question
/// steps; the welcome, analysis and subscription steps present their own
/// full-screen layouts. Only one route (`/onboarding`) is registered — steps
/// are pages, matching the design's persistent progress bar.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  // Page indices.
  static const int _welcome = 0;
  static const int _chooseProblem = 1;
  static const int _q1 = 2;
  static const int _q2 = 3;
  static const int _q3 = 4;
  static const int _analysis = 5;
  static const int _plan = 6;
  static const int _subscription = 7;

  static const int _progressStepCount = 6; // choose-problem … plan

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
    // From the plan screen, skip the analysis screen back to the last question.
    final target = _index == _plan ? _q3 : _index - 1;
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

  bool get _showChrome => _index >= _chooseProblem && _index <= _plan;
  bool get _showBack =>
      _index == _q1 || _index == _q2 || _index == _q3 || _index == _plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSize(
              duration: AppConstants.shortAnimation,
              child: _showChrome
                  ? _TopChrome(
                      showBack: _showBack,
                      onBack: _back,
                      stepCount: _progressStepCount,
                      currentStep: (_index - _chooseProblem)
                          .clamp(0, _progressStepCount - 1),
                    )
                  : const SizedBox(width: double.infinity),
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
          ],
        ),
      ),
    );
  }
}

class _TopChrome extends StatelessWidget {
  const _TopChrome({
    required this.showBack,
    required this.onBack,
    required this.stepCount,
    required this.currentStep,
  });

  final bool showBack;
  final VoidCallback onBack;
  final int stepCount;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: showBack
                ? IconButton(
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    iconSize: AppSizes.iconMd,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  )
                : null,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: OnboardingProgressBar(
              stepCount: stepCount,
              currentStep: currentStep,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
