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
    final media = MediaQuery.of(context);
    final illoHeight = (media.size.height * 0.26).clamp(180.0, 260.0);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        showAuthErrorDialog(context, next.error as Failure);
      }
    });

    return Scaffold(
      backgroundColor: AuthStyle.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Lavender header + full-bleed hero illustration ──
                DecoratedBox(
                  decoration:
                      const BoxDecoration(gradient: AuthStyle.pageGradient),
                  child: Column(
                    children: [
                      const SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              AuthStyle.s24, AuthStyle.s24, AuthStyle.s24, 0),
                          child: Column(
                            children: [
                              SlideFadeIn(child: AuthLogo()),
                              SizedBox(height: AuthStyle.s20),
                              SlideFadeIn(
                                delay: Duration(milliseconds: 60),
                                child: Text('Welcome back!',
                                    textAlign: TextAlign.center,
                                    style: AuthStyle.title),
                              ),
                              SizedBox(height: AuthStyle.s8),
                              SlideFadeIn(
                                delay: Duration(milliseconds: 90),
                                child: Text('Continue your healing journey.',
                                    textAlign: TextAlign.center,
                                    style: AuthStyle.subtitle),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SlideFadeIn(
                        delay: const Duration(milliseconds: 120),
                        offset: 0,
                        child: AuthHeroImage(height: illoHeight),
                      ),
                    ],
                  ),
                ),
                // ── White form card overlapping the hero ──
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuthStyle.surface,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AuthStyle.cardRadius)),
                      boxShadow: AuthStyle.cardShadow,
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
                          const SizedBox(height: AuthStyle.s20),
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
                          const SizedBox(height: AuthStyle.s12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => context
                                      .push(AuthRoutePaths.forgotPassword),
                              child: const Text('Forgot Password?',
                                  style: AuthStyle.link),
                            ),
                          ),
                          const SizedBox(height: AuthStyle.s24),
                          SlideFadeIn(
                            delay: const Duration(milliseconds: 220),
                            child: AuthGradientButton(
                              label: 'Sign In',
                              isLoading: isLoading,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: AuthStyle.s28),
                          const AuthOrDivider(label: 'OR CONTINUE WITH'),
                          const SizedBox(height: AuthStyle.s24),
                          SlideFadeIn(
                            delay: const Duration(milliseconds: 250),
                            child: GoogleSignInButton(
                              onPressed: isLoading ? null : _signInWithGoogle,
                            ),
                          ),
                          const SizedBox(height: AuthStyle.s28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ",
                                  style: AuthStyle.muted),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () =>
                                        context.push(AuthRoutePaths.register),
                                child: const Text('Create Account',
                                    style: AuthStyle.link),
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
