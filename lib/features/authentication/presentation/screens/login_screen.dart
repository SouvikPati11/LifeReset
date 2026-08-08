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
import 'auth_routes.dart';

/// Email / password sign-in screen — also the entry point for Google sign-in
/// and, transparently, admin sign-in (role is resolved after authentication).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    // Navigation is handled by the router's auth guard on success.
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;
    final textTheme = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final illoHeight = (media.size.height * 0.28).clamp(190.0, 280.0);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        showAuthErrorDialog(context, next.error as Failure);
      }
    });

    return Scaffold(
      // White scaffold so the sheet blends; the header region paints its own
      // lavender tint behind the logo / title and the illustration.
      backgroundColor: AuthStyle.cardSurface(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header + full-bleed illustration on the lavender tint ──
                Container(
                  color: AuthStyle.pageBackground(context),
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AuthStyle.s24, AuthStyle.s16, AuthStyle.s24, 0),
                          child: Column(
                            children: [
                              const SlideFadeIn(child: AuthLogo()),
                              const SizedBox(height: AuthStyle.s16),
                              SlideFadeIn(
                                delay: const Duration(milliseconds: 60),
                                child: Text('Welcome back!',
                                    textAlign: TextAlign.center,
                                    style: AuthStyle.title(context)),
                              ),
                              const SizedBox(height: AuthStyle.s8),
                              SlideFadeIn(
                                delay: const Duration(milliseconds: 90),
                                child: Text('Continue your healing journey.',
                                    textAlign: TextAlign.center,
                                    style: AuthStyle.subtitle(context)),
                              ),
                              const SizedBox(height: AuthStyle.s16),
                            ],
                          ),
                        ),
                      ),
                      SlideFadeIn(
                        delay: const Duration(milliseconds: 120),
                        child: AuthHeroImage(height: illoHeight),
                      ),
                    ],
                  ),
                ),
                // ── Form sheet overlapping the illustration ──
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuthStyle.cardSurface(context),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha:
                                  Theme.of(context).brightness == Brightness.dark
                                      ? 0.4
                                      : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(AuthStyle.s24, AuthStyle.s32,
                        AuthStyle.s24, AuthStyle.s24 + media.padding.bottom),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SlideFadeIn(
                            delay: const Duration(milliseconds: 160),
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
                            delay: const Duration(milliseconds: 190),
                            child: AuthTextInput(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              obscurable: true,
                              textInputAction: TextInputAction.done,
                              validator: AuthValidators.password,
                              enabled: !isLoading,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _submit(),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context
                                      .push(AuthRoutePaths.forgotPassword),
                              style: TextButton.styleFrom(
                                  foregroundColor: AuthStyle.accent),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: AuthStyle.s8),
                          SlideFadeIn(
                            delay: const Duration(milliseconds: 220),
                            child: AuthGradientButton(
                              label: 'Sign In',
                              isLoading: isLoading,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: AuthStyle.s24),
                          const AuthOrDivider(label: 'OR CONTINUE WITH'),
                          const SizedBox(height: AuthStyle.s24),
                          SlideFadeIn(
                            delay: const Duration(milliseconds: 250),
                            child: GoogleSignInButton(
                              onPressed: isLoading ? null : _signInWithGoogle,
                            ),
                          ),
                          const SizedBox(height: AuthStyle.s24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? ",
                                  style: textTheme.bodyMedium),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () =>
                                        context.push(AuthRoutePaths.register),
                                child: Text(
                                  'Create Account',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
