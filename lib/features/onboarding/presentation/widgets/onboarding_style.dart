import 'package:flutter/material.dart';

/// Local purple visual identity for the onboarding flow, matching the approved
/// Login/Register design (#7C3AED). Applied only within the onboarding surfaces
/// so the rest of the app's (teal) theme is untouched.
class OnboardingStyle {
  const OnboardingStyle._();

  static const Color accent = Color(0xFF7C3AED);
  static const Color purpleStart = Color(0xFF6D28FF);
  static const Color purpleEnd = Color(0xFF8B5CF6);

  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purpleStart, purpleEnd],
  );

  static const Color pageTop = Color(0xFFF3F0FB);
  static const Color pageBottom = Color(0xFFFBFAFE);
  static const Color surface = Colors.white;
  static const Color selectedFill = Color(0xFFF3EEFF);
  static const Color border = Color(0xFFE6E4F0);
  static const Color ink = Color(0xFF1A1B2E);
  static const Color bodyGray = Color(0xFF6B7280);
  static const Color chipBg = Color(0xFFF1ECFC);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [pageTop, pageBottom],
  );

  static const double fieldRadius = 16;
  static const double buttonHeight = 56;
  static const double buttonRadius = 16;

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: purpleStart.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  static const TextStyle title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.4,
    color: ink,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: bodyGray,
  );
}

/// The purple-gradient primary CTA used across onboarding (56 high, radius 16,
/// soft shadow, optional trailing arrow and a built-in loading state).
class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.showArrow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: OnboardingStyle.gradient,
          borderRadius: BorderRadius.circular(OnboardingStyle.buttonRadius),
          boxShadow: enabled ? OnboardingStyle.buttonShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(OnboardingStyle.buttonRadius),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: OnboardingStyle.buttonHeight,
              width: double.infinity,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (showArrow) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 20),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The bottom page-dot progress indicator from the Figma: the current step is a
/// wide pill, completed/upcoming steps are small dots.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i <= current
                  ? OnboardingStyle.accent
                  : const Color(0xFFDDD8EC),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}
