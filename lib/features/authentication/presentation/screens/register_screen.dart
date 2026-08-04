import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../controllers/auth_controller.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_error_dialog.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_style.dart';

/// Email / password account creation screen.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _agreed = false;
  String _password = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    // On success the router's auth guard routes the (unverified) user to the
    // verify-email screen — no manual navigation needed here.
    await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;
    final textTheme = Theme.of(context).textTheme;

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        showAuthErrorDialog(context, next.error as Failure);
      }
    });

    return Scaffold(
      backgroundColor: AuthStyle.pageBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AuthStyle.s24, 0, AuthStyle.s24, AuthStyle.s32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SlideFadeIn(
                        child: Center(child: AuthLogo(fontSize: 24))),
                    const SizedBox(height: AuthStyle.s24),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 60),
                      child: Text('Create your account',
                          textAlign: TextAlign.center,
                          style: AuthStyle.title(context)),
                    ),
                    const SizedBox(height: AuthStyle.s8),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 90),
                      child: Text(
                        'Start your 30-day recovery journey.',
                        textAlign: TextAlign.center,
                        style: AuthStyle.subtitle(context),
                      ),
                    ),
                    const SizedBox(height: AuthStyle.s32),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 120),
                      child: AuthTextInput(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: AuthValidators.displayName,
                        enabled: !isLoading,
                        autofillHints: const [AutofillHints.name],
                      ),
                    ),
                    const SizedBox(height: AuthStyle.s16),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 150),
                      child: AuthTextInput(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter your email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: AuthValidators.email,
                        enabled: !isLoading,
                        autofillHints: const [AutofillHints.email],
                      ),
                    ),
                    const SizedBox(height: AuthStyle.s16),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 180),
                      child: AuthTextInput(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Create a password',
                        icon: Icons.lock_outline_rounded,
                        obscurable: true,
                        textInputAction: TextInputAction.next,
                        validator: AuthValidators.password,
                        enabled: !isLoading,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: (v) => setState(() => _password = v),
                      ),
                    ),
                    if (_password.isNotEmpty) ...[
                      const SizedBox(height: AuthStyle.s12),
                      PasswordStrengthMeter(password: _password),
                    ],
                    const SizedBox(height: AuthStyle.s16),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 210),
                      child: AuthTextInput(
                        controller: _confirmController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        icon: Icons.lock_outline_rounded,
                        obscurable: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) => AuthValidators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(height: AuthStyle.s24),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 240),
                      child: AuthTermsCheckbox(
                        value: _agreed,
                        onChanged: isLoading
                            ? (_) {}
                            : (v) => setState(() => _agreed = v),
                      ),
                    ),
                    const SizedBox(height: AuthStyle.s24),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 270),
                      child: AuthGradientButton(
                        label: 'Create Account',
                        isLoading: isLoading,
                        onPressed: _agreed ? _submit : null,
                      ),
                    ),
                    const SizedBox(height: AuthStyle.s24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                            style: textTheme.bodyMedium),
                        GestureDetector(
                          onTap: isLoading ? null : () => context.pop(),
                          child: Text(
                            'Sign In',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AuthStyle.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
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
