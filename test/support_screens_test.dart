import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifereset/features/authentication/domain/entities/auth_user.dart';
import 'package:lifereset/features/authentication/presentation/providers/auth_providers.dart';
import 'package:lifereset/features/profile/domain/entities/user_profile.dart';
import 'package:lifereset/features/profile/presentation/providers/profile_providers.dart';
import 'package:lifereset/features/profile/presentation/screens/settings_screen.dart';
import 'package:lifereset/features/support/domain/entities/support_content.dart';
import 'package:lifereset/features/support/presentation/providers/support_providers.dart';
import 'package:lifereset/features/support/presentation/screens/contact_support_screen.dart';
import 'package:lifereset/features/support/presentation/screens/faq_screen.dart';
import 'package:lifereset/features/support/presentation/screens/help_center_screen.dart';
import 'package:lifereset/features/support/presentation/screens/terms_screen.dart';
import 'package:lifereset/theme/theme_controller.dart';

List<Override> _overrides({
  LegalPage? terms,
  LegalPage? help,
  List<FaqEntry>? faqs,
  SupportInfo? support,
}) =>
    [
      termsProvider.overrideWith((ref) => Stream.value(terms ?? LegalPage.empty())),
      helpContentProvider
          .overrideWith((ref) => Stream.value(help ?? LegalPage.empty())),
      faqsProvider.overrideWith((ref) => Stream.value(faqs ?? const [])),
      supportInfoProvider
          .overrideWith((ref) => Stream.value(support ?? SupportInfo.empty())),
    ];

Widget _host(Widget child, List<Override> overrides,
    {Size size = const Size(390, 2600)}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: MediaQuery(data: MediaQueryData(size: size), child: child),
    ),
  );
}

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 300));
  await t.pump(const Duration(milliseconds: 300));
}

Future<void> _pump(WidgetTester t, Widget app,
    {Size size = const Size(390, 2600)}) async {
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = size;
  await t.pumpWidget(app);
  await _settle(t);
}

void main() {
  tearDown(() {
    final v = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    v.resetPhysicalSize();
    v.resetDevicePixelRatio();
  });

  test('theme is pinned to Light only', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeControllerProvider), ThemeMode.light);
    // setThemeMode is a no-op: the app can never move off Light.
    container.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
    expect(container.read(themeControllerProvider), ThemeMode.light);
  });

  testWidgets('Terms shows admin-managed content', (t) async {
    await _pump(
      t,
      _host(
        const TermsScreen(),
        _overrides(
          terms: const LegalPage(
              title: 'Terms of Service', body: 'These are the terms you agree to.'),
        ),
      ),
    );
    expect(find.text('These are the terms you agree to.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Terms shows a graceful empty state when unpublished', (t) async {
    await _pump(t, _host(const TermsScreen(), _overrides()));
    expect(find.text('No content is available yet.'), findsOneWidget);
    // No "Coming soon" placeholder wording.
    expect(find.textContaining("We're still building this"), findsNothing);
  });

  testWidgets('FAQs render and expand to reveal answers', (t) async {
    await _pump(
      t,
      _host(
        const FaqScreen(),
        _overrides(faqs: const [
          FaqEntry(id: 'f1', question: 'How do I reset my streak?', answer: 'Tap reset.'),
          FaqEntry(id: 'f2', question: 'Is my data private?', answer: 'Yes, always.'),
        ]),
      ),
    );
    expect(find.text('How do I reset my streak?'), findsOneWidget);
    expect(find.text('Is my data private?'), findsOneWidget);
    // Answer is collapsed until tapped.
    await t.tap(find.text('How do I reset my streak?'));
    await _settle(t);
    expect(find.text('Tap reset.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('FAQs empty state', (t) async {
    await _pump(t, _host(const FaqScreen(), _overrides()));
    expect(find.text('No content is available yet.'), findsOneWidget);
  });

  testWidgets('Contact Support shows configured info', (t) async {
    await _pump(
      t,
      _host(
        const ContactSupportScreen(),
        _overrides(
          support: const SupportInfo(
            email: 'help@lifereset.app',
            phone: '+1 555 0100',
            message: 'We reply within a day.',
          ),
        ),
      ),
    );
    expect(find.text('We reply within a day.'), findsOneWidget);
    expect(find.text('help@lifereset.app'), findsOneWidget);
    expect(find.text('+1 555 0100'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Contact Support empty state', (t) async {
    await _pump(t, _host(const ContactSupportScreen(), _overrides()));
    expect(find.text('No content is available yet.'), findsOneWidget);
  });

  testWidgets('Help Center hub links to FAQs', (t) async {
    await _pump(
      t,
      _host(
        const HelpCenterScreen(),
        _overrides(
          help: const LegalPage(title: 'How can we help?', body: 'Browse below.'),
          faqs: const [
            FaqEntry(id: 'f1', question: 'A question?', answer: 'An answer.'),
          ],
        ),
      ),
    );
    expect(find.text('How can we help?'), findsOneWidget);
    expect(find.text('FAQs'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
    await t.tap(find.text('FAQs'));
    await _settle(t);
    expect(find.byType(FaqScreen), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Settings → Help Center opens the real screen, not a placeholder',
      (t) async {
    const profile = UserProfile(
      uid: 'u1', name: 'Alex', email: 'a@b.com',
      plan: SubscriptionPlan.free, trialStatus: TrialStatus.none,
      appearance: AppearanceMode.light, language: 'en',
      notificationsEnabled: true, remindersEnabled: false,
      recoveryScore: 10, currentDay: 1, streak: 0, completedTasks: 0,
    );
    await _pump(
      t,
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(
              const AuthUser(id: 'u1', email: 'a@b.com', isEmailVerified: true)),
          profileProvider.overrideWith((ref) => Stream.value(profile)),
          ..._overrides(
            help: const LegalPage(title: 'How can we help?', body: 'Ask us.'),
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(390, 2600)),
            child: SettingsScreen(),
          ),
        ),
      ),
    );
    // The Settings "Support" group lists Help Center.
    expect(find.text('Help Center'), findsOneWidget);
    await t.tap(find.text('Help Center'));
    await _settle(t);
    // Opens the real content screen — never the "Coming soon" placeholder.
    expect(find.byType(HelpCenterScreen), findsOneWidget);
    expect(find.text('How can we help?'), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    expect(find.textContaining('still building this'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('no overflow across widths for support screens', (t) async {
    final screens = <String, Widget>{
      'Terms': const TermsScreen(),
      'FAQ': const FaqScreen(),
      'Contact': const ContactSupportScreen(),
      'Help': const HelpCenterScreen(),
    };
    final overrides = _overrides(
      terms: const LegalPage(title: 'Terms', body: 'Body text here.'),
      help: const LegalPage(title: 'Help', body: 'Help body.'),
      faqs: const [
        FaqEntry(id: 'f1', question: 'A fairly long question that wraps?', answer: 'Yes.'),
      ],
      support: const SupportInfo(
          email: 'help@lifereset.app', phone: '+1 555 0100', message: 'Hello there.'),
    );
    for (final w in const [320.0, 360.0, 390.0, 430.0]) {
      for (final entry in screens.entries) {
        await _pump(t, _host(entry.value, overrides, size: Size(w, 2600)),
            size: Size(w, 2600));
        expect(t.takeException(), isNull,
            reason: 'overflow on ${entry.key} @ ${w}px');
      }
    }
  });
}
