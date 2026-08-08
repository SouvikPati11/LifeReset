import 'package:flutter/material.dart';

import 'auth_style.dart';

/// A premium auth input matching the Figma: external bold label, a 58-high
/// white rounded field with a soft lavender border, a purple prefix icon, and
/// an animated show/hide toggle for password fields. Wraps [TextFormField] so
/// all existing validation / controller wiring is preserved by the caller.
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthStyle.fieldRadius),
      borderSide: const BorderSide(color: AuthStyle.fieldBorder),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AuthStyle.label),
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
            hintStyle: const TextStyle(
              color: AuthStyle.placeholder,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AuthStyle.surface,
            constraints:
                const BoxConstraints(minHeight: AuthStyle.fieldHeight),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AuthStyle.s16, vertical: 18),
            prefixIcon: Icon(widget.icon, size: 20, color: AuthStyle.accent),
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
                        color: AuthStyle.iconMuted,
                      ),
                    ),
                  )
                : null,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AuthStyle.accent, width: 1.6),
            ),
            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: Color(0xFFE0576B)),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: const BorderSide(color: Color(0xFFE0576B), width: 1.6),
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
        return const PasswordStrength(4, 'Strong', AuthStyle.strongGreen);
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
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < filled
                          ? AuthStyle.purpleEnd
                          : const Color(0xFFE6E4F0),
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
    const linkStyle = TextStyle(
      fontSize: 14,
      color: AuthStyle.accent,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? AuthStyle.accent : AuthStyle.surface,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: value ? AuthStyle.accent : AuthStyle.fieldBorder,
                width: 1.6,
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded,
                    size: 16, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: AuthStyle.s12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AuthStyle.labelInk,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: linkStyle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AuthStyle.accent),
                  ),
                  const TextSpan(text: ' and '),
                  const TextSpan(text: 'Privacy Policy', style: linkStyle),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
