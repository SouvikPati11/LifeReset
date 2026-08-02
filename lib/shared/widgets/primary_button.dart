import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import 'loading_view.dart';

/// The app's primary call-to-action button.
///
/// Wraps [FilledButton] with a built-in loading state so screens don't
/// reimplement the "disable + spinner while submitting" pattern.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const InlineLoader(size: AppSizes.iconMd)
        : _buildLabel();

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildLabel() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm),
        const SizedBox(width: AppSizes.sm),
        Text(label),
      ],
    );
  }
}
