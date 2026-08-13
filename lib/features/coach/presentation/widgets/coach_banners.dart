import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';

/// The standing safety disclaimer required on the AI Coach surfaces.
class SafetyDisclaimer extends StatelessWidget {
  const SafetyDisclaimer({super.key});

  static const String text =
      'AI Coach provides emotional support but is not a licensed therapist.';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: HomeStyle.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_moon_rounded,
              size: 16, color: HomeStyle.primary),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: HomeStyle.inkSoft,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emergency support banner shown when a crisis/self-harm message is detected.
class CrisisBanner extends StatelessWidget {
  const CrisisBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  static const Color _bg = Color(0xFFFEF2F2);
  static const Color _fg = Color(0xFFB91C1C);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, 0),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_rounded, color: _fg),
          const SizedBox(width: AppSizes.sm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are not alone',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _fg,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'If you are in crisis, please contact your local emergency '
                  'number or a crisis helpline right now. Real help is '
                  'available.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF7F1D1D),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, color: _fg),
          ),
        ],
      ),
    );
  }
}

/// Banner shown when the daily free message limit is reached.
class LimitBanner extends StatelessWidget {
  const LimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, 0),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: HomeStyle.lavender,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: HomeStyle.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_clock_rounded, color: HomeStyle.primaryDeep),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              "You've reached today's message limit. Upgrade to Premium for "
              'unlimited chats.',
              style: TextStyle(
                fontSize: 12.5,
                color: HomeStyle.primaryDeep,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
