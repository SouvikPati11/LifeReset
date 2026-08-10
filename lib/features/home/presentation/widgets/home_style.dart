import 'package:flutter/material.dart';

/// Local wellness visual identity for the Home dashboard.
///
/// Home commits to a calm, light purple/mint palette (the spec's colour
/// system) applied only within the Home surfaces, so the rest of the app's
/// seeded theme is untouched. Purple is reserved for the primary accents
/// (score ring, active states, key highlights); the majority stays light.
class HomeStyle {
  const HomeStyle._();

  // Purple accents.
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDeep = Color(0xFF6D28D9);
  static const Color primarySoft = Color(0xFF9F7AEA);
  static const Color lavender = Color(0xFFEDE9FE);
  static const Color lavenderLight = Color(0xFFF5F3FF);

  // Surfaces & text.
  static const Color background = Color(0xFFFAFAF9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F2937);
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color border = Color(0xFFEDEAF4);

  // Mint / success.
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFECFDF5);

  // Insight card wash.
  static const Color insightBg = Color(0xFFF4F0FE);

  /// The purple hero gradient for the recovery-score card.
  static const LinearGradient scoreGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), primary],
  );

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF6D28D9).withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  /// The encouraging caption shown under the recovery score, tiered by score.
  /// Mirrors the onboarding tiers so the message stays consistent end-to-end.
  static String scoreCaption(int score) {
    if (score < 60) return "Let's begin 💜";
    if (score < 75) return 'Good Start! Keep going 💜';
    if (score < 87) return "You're making progress 💜";
    return "You're on your way 💜";
  }
}

/// The user's personalized "Focus", derived from the onboarding problem stored
/// on `users/{uid}.problem`. Never shows a raw enum value; falls back to a
/// sensible generic focus when the field is missing.
class HomeFocus {
  const HomeFocus({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  /// Maps the stored `problem` string to a human focus. Values match
  /// `OnboardingProblem.value` without importing the onboarding feature.
  factory HomeFocus.fromProblem(String? problem) {
    switch (problem) {
      case 'breakup_recovery':
        return const HomeFocus(
          title: 'Healing & Moving Forward',
          subtitle:
              'Your recovery journey is focused on helping you move forward.',
          icon: Icons.favorite_rounded,
        );
      case 'anxiety_stress':
        return const HomeFocus(
          title: 'Finding Calm & Balance',
          subtitle: 'Your journey is focused on easing stress and finding calm.',
          icon: Icons.self_improvement_rounded,
        );
      case 'low_confidence':
        return const HomeFocus(
          title: 'Building Self-Worth',
          subtitle: 'Your journey is focused on rebuilding your confidence.',
          icon: Icons.workspace_premium_rounded,
        );
      case 'overthinking':
        return const HomeFocus(
          title: 'Quieting Your Mind',
          subtitle: 'Your journey is focused on calming a busy mind.',
          icon: Icons.psychology_rounded,
        );
      default:
        return const HomeFocus(
          title: 'Your Recovery Journey',
          subtitle: 'Personalized support as you take each step forward.',
          icon: Icons.spa_rounded,
        );
    }
  }
}
