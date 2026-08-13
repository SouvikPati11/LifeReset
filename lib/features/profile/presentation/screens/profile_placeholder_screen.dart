import 'package:flutter/material.dart';

import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';

/// Placeholder destination for navigation-only profile items (Help Center,
/// FAQ, Privacy Policy, Terms, Billing History, etc.).
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key, required this.title});

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
                icon: Icons.info_outline_rounded,
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
