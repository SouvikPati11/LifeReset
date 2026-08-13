import 'package:flutter/material.dart';

import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';

/// Placeholder destination for the AI Coach's navigation-only actions
/// (quick actions / suggested tools whose modules are not built yet).
class CoachPlaceholderScreen extends StatelessWidget {
  const CoachPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const Expanded(
              child: LsEmpty(
                icon: Icons.spa_rounded,
                title: 'Coming soon',
                message: "We're still building this. Check back shortly.",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
