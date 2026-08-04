import 'package:flutter/material.dart';

import 'auth_style.dart';

/// A premium auth input: external label, 56-high rounded field (radius 18),
/// soft border with a purple focus state, a tinted prefix icon, and an animated
/// show/hide toggle for password fields. Wraps [TextFormField] so all existing
/// validation / controller wiring is preserved by the caller.
class AuthTextInput extends StatefulWidget {
  const AuthTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscurable = false,
    this.enabled = true,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscurable;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  @override
  State<AuthTextInput> createState() => _AuthTextInputState();
}

class _AuthTextInputState extends State<AuthTextInput> {
  late bool _obscured = widget.obscurable;
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focused != _focusNode.hasFocus) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor =
        _focused ? AuthStyle.accent : colorScheme.onSurfaceVariant;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthStyle.fieldRadius),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AuthStyle.label(context)),
        const SizedBox(height: AuthStyle.s8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: widget.onChanged,
          style: AuthStyle.input,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: AuthStyle.accent,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: AuthStyle.cardSurface(context),
            constraints:
                const BoxConstraints(minHeight: AuthStyle.fieldHeight),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AuthStyle.s16, vertical: 18),
            prefixIcon: Icon(widget.icon, size: 20, color: iconColor),
            suffixIcon: widget.obscurable
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(_obscured),
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : null,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AuthStyle.accent, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// Strength of a password on a 0–4 scale, with a label and colour.
class PasswordStrength {
  const PasswordStrength(this.score, this.label, this.color);
  final int score; // 0..4
  final String label;
  final Color color;

  static PasswordStrength of(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(0, '', Color(0xFF9E9E9E));
    }
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password)) {
      score++;
    }
    switch (score) {
      case 0:
      case 1:
        return const PasswordStrength(1, 'Weak', Color(0xFFE0576B));
      case 2:
        return const PasswordStrength(2, 'Fair', Color(0xFFE0A800));
      case 3:
        return const PasswordStrength(3, 'Good', AuthStyle.purpleEnd);
      default:
        return const PasswordStrength(4, 'Strong', Color(0xFF2E9E63));
    }
  }
}

/// A 5-segment password-strength indicator with a trailing label.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = PasswordStrength.of(password);
    final filled = password.isEmpty ? 0 : strength.score + 1; // 1..5
    final empty = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i != 0) const SizedBox(width: 6),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < filled ? AuthStyle.purpleEnd : empty,
                      borderRadius: BorderRadius.circular(AuthStyle.radiusPill),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (strength.label.isNotEmpty) ...[
          const SizedBox(width: AuthStyle.s12),
          Text(
            strength.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: strength.color,
            ),
          ),
        ],
      ],
    );
  }
}

/// The "I agree to the Terms of Service and Privacy Policy" checkbox row.
class AuthTermsCheckbox extends StatelessWidget {
  const AuthTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final linkStyle = textTheme.bodyMedium?.copyWith(
      color: AuthStyle.accent,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AuthStyle.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AuthStyle.s12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text.rich(
              TextSpan(
                style: textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(text: 'Terms of Service', style: linkStyle),
                  const TextSpan(text: ' and '),
                  TextSpan(text: 'Privacy Policy', style: linkStyle),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
