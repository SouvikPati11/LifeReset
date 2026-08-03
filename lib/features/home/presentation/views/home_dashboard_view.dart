import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../screens/todays_plan_screen.dart';
import '../widgets/coming_soon_view.dart';
import '../widgets/daily_inspiration_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recovery_score_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/todays_plan_card.dart';
import '../widgets/weekly_overview_card.dart';

/// The Home tab: the full recovery dashboard.
class HomeDashboardView extends ConsumerWidget {
  const HomeDashboardView({super.key});

  void _openPlan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TodaysPlanScreen()),
    );
  }

  void _openComingSoon(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonView(title: title, showAppBar: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = _firstName(
      ref.watch(userProfileProvider).valueOrNull?.name,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.md,
          AppSizes.md,
          AppSizes.xl,
        ),
        children: [
          _GreetingHeader(
            name: firstName,
            onNotifications: () => _openComingSoon(context, 'Notifications'),
          ),
          const SizedBox(height: AppSizes.lg),
          const RecoveryScoreCard(),
          const SizedBox(height: AppSizes.md),
          TodaysPlanCard(onOpenPlan: () => _openPlan(context)),
          const SizedBox(height: AppSizes.lg),
          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          QuickActionsGrid(
            onOpen: (title) => _openComingSoon(context, title),
          ),
          const SizedBox(height: AppSizes.lg),
          Text('Daily Inspiration',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          const DailyInspirationCard(),
          const SizedBox(height: AppSizes.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(child: StreakCard()),
                SizedBox(width: AppSizes.md),
                Expanded(child: WeeklyOverviewCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _firstName(String? fullName) {
    final name = (fullName ?? '').trim();
    if (name.isEmpty) return 'there';
    return name.split(' ').first;
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name, required this.onNotifications});

  final String name;
  final VoidCallback onNotifications;

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_timeGreeting, $name 👋',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text("You've got this!", style: textTheme.headlineMedium),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Every small step counts. Keep going.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
