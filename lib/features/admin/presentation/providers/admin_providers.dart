import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_models.dart';
import '../../domain/repositories/admin_repository.dart';

/// Dependency graph + cached section providers for the Admin Panel.

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(
    AdminRemoteDataSource(FirebaseFirestore.instance),
  );
});

// Dashboard (cached; graceful empty on failure so the UI still renders).
final dashboardStatsProvider = FutureProvider<AdminStats>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getStats();
  return r.when(success: (s) => s, failure: (_) => AdminStats.empty());
});

final signupActivityProvider = FutureProvider<List<ActivityPoint>>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getSignupActivity();
  return r.when(success: (a) => a, failure: (_) => const []);
});

final recentUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getRecentUsers();
  return r.when(success: (u) => u, failure: (_) => const []);
});

final topProgramsProvider = FutureProvider<List<TopProgram>>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getTopPrograms();
  return r.when(success: (p) => p, failure: (_) => const []);
});

final systemStatusProvider = FutureProvider<List<SystemService>>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getSystemStatus();
  return r.when(success: (s) => s, failure: (_) => const []);
});

/// Users grouped by onboarding recovery area (read-only Dashboard donut).
final problemDistributionProvider =
    FutureProvider<List<ProblemDistribution>>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getProblemDistribution();
  return r.when(success: (d) => d, failure: (_) => const []);
});

/// Daily Tracking (mood check-in) analytics.
final trackingAnalyticsProvider = FutureProvider<TrackingAnalytics>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getTrackingAnalytics();
  return r.when(success: (a) => a, failure: (_) => TrackingAnalytics.empty());
});

/// Recovery-progress analytics.
final progressAnalyticsProvider = FutureProvider<ProgressAnalytics>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getProgressAnalytics();
  return r.when(success: (a) => a, failure: (_) => ProgressAnalytics.empty());
});

/// AI Coach usage analytics (privacy-preserving counts only).
final coachAnalyticsProvider = FutureProvider<CoachAnalytics>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getCoachAnalytics();
  return r.when(success: (a) => a, failure: (_) => CoachAnalytics.empty());
});

/// Administrator accounts (role == admin).
final adminUsersListProvider = StreamProvider<List<AdminUser>>(
    (ref) => ref.watch(adminRepositoryProvider).watchAdminUsers());

/// Append-only admin audit trail.
final auditLogsProvider = StreamProvider<List<AuditLogEntry>>(
    (ref) => ref.watch(adminRepositoryProvider).watchAuditLogs());

// Content streams.
final programsProvider = StreamProvider<List<ProgramItem>>(
    (ref) => ref.watch(adminRepositoryProvider).watchPrograms());

final programTasksProvider =
    StreamProvider.family<List<ProgramTaskItem>, String>(
        (ref, pid) => ref.watch(adminRepositoryProvider).watchTasks(pid));

final promptsProvider = StreamProvider<List<PromptItem>>(
    (ref) => ref.watch(adminRepositoryProvider).watchPrompts());

final quotesProvider = StreamProvider<List<QuoteItem>>(
    (ref) => ref.watch(adminRepositoryProvider).watchQuotes());

final faqsAdminProvider = StreamProvider<List<FaqItem>>(
    (ref) => ref.watch(adminRepositoryProvider).watchFaqs());

/// An admin-editable content page (Terms of Service, Help Center) by doc id.
final contentPageProvider = StreamProvider.family<ContentPage, String>(
    (ref, docId) => ref.watch(adminRepositoryProvider).watchContentPage(docId));

final adminNotificationsProvider = StreamProvider<List<AdminNotificationItem>>(
    (ref) => ref.watch(adminRepositoryProvider).watchNotifications());

final transactionsProvider = StreamProvider<List<TransactionItem>>(
    (ref) => ref.watch(adminRepositoryProvider).watchTransactions());

final settingsProvider = StreamProvider<AppSettings>(
    (ref) => ref.watch(adminRepositoryProvider).watchSettings());

// Analytics / subscriptions.
final analyticsProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getAnalytics();
  return r.when(success: (a) => a, failure: (_) => AnalyticsSummary.empty());
});

final subscriptionSummaryProvider =
    FutureProvider<SubscriptionSummary>((ref) async {
  final r = await ref.watch(adminRepositoryProvider).getSubscriptionSummary();
  return r.when(success: (s) => s, failure: (_) => SubscriptionSummary.empty());
});
