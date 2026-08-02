import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Describes the current form factor based on the available width.
enum FormFactor { mobile, tablet, desktop }

/// Renders different layouts per form factor using the app's breakpoints.
///
/// Only [mobile] is required; [tablet] and [desktop] fall back to the next
/// smaller layout when not provided, so screens can adopt larger layouts
/// incrementally.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  static FormFactor formFactorOf(double width) {
    if (width >= AppSizes.tabletBreakpoint) return FormFactor.desktop;
    if (width >= AppSizes.mobileBreakpoint) return FormFactor.tablet;
    return FormFactor.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (formFactorOf(constraints.maxWidth)) {
          case FormFactor.desktop:
            return desktop ?? tablet ?? mobile;
          case FormFactor.tablet:
            return tablet ?? mobile;
          case FormFactor.mobile:
            return mobile;
        }
      },
    );
  }
}

/// Constrains content to [AppSizes.maxContentWidth] and centers it, keeping
/// wide screens readable. Wrap page bodies in this for consistent gutters.
class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
