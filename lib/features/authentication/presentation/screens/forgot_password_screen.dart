import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/success_view.dart';
import '../controllers/auth_controller.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_text_field.dart';

/// Password-reset request screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;
    final textTheme = Theme.of(context).textTheme;

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next is AsyncError && mounted) {
        final failure = next.error;
        final message =
            failure is Failure ? failure.message : 'Something went wrong.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: ContentContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: _emailSent
              ? SuccessView(
                  title: 'Check your inbox',
                  message:
                      'We sent a password reset link to ${_emailController.text.trim()}.',
                  action: PrimaryButton(
                    label: 'Back to sign in',
                    expand: false,
                    onPressed: () => context.pop(),
                  ),
                )
              : SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSizes.md),
                        Text('Forgot your password?',
                            style: textTheme.headlineSmall),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Enter your email and we will send you a link to reset it.',
                          style: textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: AuthValidators.email,
                          enabled: !isLoading,
                          autofillHints: const [AutofillHints.email],
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        PrimaryButton(
                          label: 'Send reset link',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
