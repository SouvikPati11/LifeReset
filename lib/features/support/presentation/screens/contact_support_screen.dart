import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../providers/support_providers.dart';

/// Contact Support — shows the admin-configured support information. Tapping an
/// email or phone copies it to the clipboard (no external launcher dependency).
class ContactSupportScreen extends ConsumerWidget {
  const ContactSupportScreen({super.key});

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label copied')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(supportInfoProvider);
    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Contact Support',
              subtitle: "We're here to help",
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: async.when(
                loading: () => const LsLoader(),
                error: (_, __) => LsErrorState(
                  title: 'Could not load support info',
                  message: 'Please check your connection and try again.',
                  onRetry: () => ref.invalidate(supportInfoProvider),
                ),
                data: (info) {
                  if (!info.hasAny) {
                    return const LsEmpty(
                      icon: Icons.support_agent_rounded,
                      title: 'No content is available yet.',
                      message:
                          'Contact information will appear here once configured.',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        decoration: BoxDecoration(
                          gradient: HomeStyle.scoreGradient,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLg),
                          boxShadow: HomeStyle.softShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Text(
                                info.message.trim().isNotEmpty
                                    ? info.message
                                    : "Reach out and we'll get back to you as "
                                        'soon as we can.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (info.email.trim().isNotEmpty ||
                          info.phone.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSizes.lg),
                        const LsGroupLabel('Get in touch'),
                        LsGroup(
                          children: [
                            if (info.email.trim().isNotEmpty)
                              LsRow(
                                icon: Icons.mail_outline_rounded,
                                title: 'Email',
                                subtitle: info.email,
                                trailing: const Icon(Icons.copy_rounded,
                                    size: 18, color: HomeStyle.inkSoft),
                                showChevron: false,
                                onTap: () =>
                                    _copy(context, 'Email', info.email),
                              ),
                            if (info.phone.trim().isNotEmpty)
                              LsRow(
                                icon: Icons.phone_outlined,
                                title: 'Phone',
                                subtitle: info.phone,
                                trailing: const Icon(Icons.copy_rounded,
                                    size: 18, color: HomeStyle.inkSoft),
                                showChevron: false,
                                onTap: () =>
                                    _copy(context, 'Phone', info.phone),
                              ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
