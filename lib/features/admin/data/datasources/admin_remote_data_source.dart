import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/content_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../onboarding/domain/entities/onboarding_answers.dart';
import '../../domain/entities/admin_models.dart';
import '../../domain/repositories/admin_repository.dart';

/// Firestore data source for the Admin Panel.
class AdminRemoteDataSource {
  AdminRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _c(String name) =>
      _db.collection(name);
  CollectionReference<Map<String, dynamic>> get _users =>
      _c(AppConstants.usersCollection);

  DateTime get _startOfToday {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime get _startOfMonth {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  Future<int> _count(Query<Map<String, dynamic>> q) async {
    final snap = await q.count().get();
    return snap.count ?? 0;
  }

  // ---- Dashboard ----

  Future<AdminStats> getStats() async {
    try {
      final results = await Future.wait([
        _count(_users),
        _count(_users.where('subscription', isEqualTo: 'premium')),
        _count(_users.where('updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfToday))),
        _count(_users.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfToday))),
      ]);
      final total = results[0];
      final premium = results[1];
      final revenueSnap = await _c('transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfMonth))
          .aggregate(sum('amount'))
          .get();
      return AdminStats(
        totalUsers: total,
        premiumUsers: premium,
        freeUsers: total - premium,
        activeToday: results[2],
        newSignups: results[3],
        monthlyRevenue: revenueSnap.getSum('amount') ?? 0,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load stats.', code: e.code);
    }
  }

  Future<List<ActivityPoint>> getSignupActivity({int days = 7}) async {
    try {
      final points = <ActivityPoint>[];
      final today = _startOfToday;
      final futures = <Future<int>>[];
      final dates = <DateTime>[];
      for (var i = days - 1; i >= 0; i--) {
        final start = today.subtract(Duration(days: i));
        final end = start.add(const Duration(days: 1));
        dates.add(start);
        futures.add(_count(_users
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('createdAt', isLessThan: Timestamp.fromDate(end))));
      }
      final counts = await Future.wait(futures);
      for (var i = 0; i < dates.length; i++) {
        points.add(ActivityPoint(date: dates[i], count: counts[i]));
      }
      return points;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load activity.', code: e.code);
    }
  }

  /// Users grouped by their onboarding recovery area. Read-only: one `.count()`
  /// aggregate per fixed [OnboardingProblem] value, run in parallel. Labels come
  /// from the enum, so no problem strings are hardcoded and the enum stays the
  /// single source of truth.
  Future<List<ProblemDistribution>> getProblemDistribution() async {
    try {
      const problems = OnboardingProblem.values;
      final counts = await Future.wait([
        for (final p in problems)
          _count(_users.where('problem', isEqualTo: p.value)),
      ]);
      return [
        for (var i = 0; i < problems.length; i++)
          ProblemDistribution(
            problemKey: problems[i].value,
            label: problems[i].label,
            count: counts[i],
          ),
      ];
    } on FirebaseException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to load problem distribution.', code: e.code);
    }
  }

  Future<List<AdminUser>> getRecentUsers({int limit = 5}) async {
    try {
      final snap = await _users
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map(_adminUser).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load users.', code: e.code);
    }
  }

  Future<List<TopProgram>> getTopPrograms({int limit = 3}) async {
    try {
      final snap = await _c('programs')
          .orderBy('userCount', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        return TopProgram(
          name: (data['name'] as String?) ?? '',
          userCount: (data['userCount'] as num?)?.toInt() ?? 0,
          iconKey: (data['icon'] as String?) ?? 'spa',
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load programs.', code: e.code);
    }
  }

  Future<List<SystemService>> getSystemStatus() async {
    // Reflects Firebase project availability plus any admin-set overrides in
    // app_config/general.services.
    const names = ['Database', 'Cloud Functions', 'Storage', 'Notifications'];
    try {
      final doc = await _c('app_config').doc('general').get();
      final services = (doc.data()?['services'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      return [
        for (final n in names)
          SystemService(name: n, healthy: (services[n] as bool?) ?? true),
      ];
    } on FirebaseException {
      return [for (final n in names) SystemService(name: n, healthy: false)];
    }
  }

  // ---- Users ----

  Future<AdminUsersPage> fetchUsersPage({DateTime? before, int limit = 15}) async {
    try {
      Query<Map<String, dynamic>> q =
          _users.orderBy('createdAt', descending: true);
      if (before != null) {
        q = q.where('createdAt', isLessThan: Timestamp.fromDate(before));
      }
      final snap = await q.limit(limit + 1).get();
      final hasMore = snap.docs.length > limit;
      final docs = hasMore ? snap.docs.take(limit) : snap.docs;
      return AdminUsersPage(
        users: docs.map(_adminUser).toList(),
        hasMore: hasMore,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load users.', code: e.code);
    }
  }

  AdminUser _adminUser(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    return AdminUser(
      uid: d.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      plan: (data['subscription'] as String?) ?? 'free',
      role: (data['role'] as String?) ?? 'user',
      status: UserStatus.fromValue(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ---- Content streams ----

  Stream<List<ProgramItem>> watchPrograms() {
    return _c('programs').snapshots().map((s) {
      final list = s.docs.map((d) {
        final data = d.data();
        return ProgramItem(
          id: d.id,
          name: (data['name'] as String?) ?? '',
          description: (data['description'] as String?) ?? '',
          totalDays: (data['totalDays'] as num?)?.toInt() ?? 30,
          status: ContentStatus.fromValue(data['status'] as String?),
          iconKey: (data['icon'] as String?) ?? 'spa',
          colorHex: (data['color'] as String?) ?? '#7C4DFF',
          userCount: (data['userCount'] as num?)?.toInt() ?? 0,
          order: (data['order'] as num?)?.toInt() ?? 0,
        );
      }).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Stream<List<ProgramTaskItem>> watchTasks(String programId) {
    return _c('program_tasks')
        .where('programId', isEqualTo: programId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) {
        final data = d.data();
        return ProgramTaskItem(
          id: d.id,
          programId: programId,
          day: (data['day'] as num?)?.toInt() ?? 1,
          order: (data['order'] as num?)?.toInt() ?? 0,
          task: (data['task'] as String?) ?? '',
          motivation: (data['motivation'] as String?) ?? '',
          journalQuestion: (data['journalQuestion'] as String?) ?? '',
          moodGoal: (data['moodGoal'] as String?) ?? '',
          aiContext: (data['aiContext'] as String?) ?? '',
          estimatedMinutes: (data['estimatedMinutes'] as num?)?.toInt() ?? 5,
          notificationText: (data['notificationText'] as String?) ?? '',
          status: ContentStatus.fromValue(data['status'] as String?),
        );
      }).toList();
      list.sort((a, b) {
        final byDay = a.day.compareTo(b.day);
        return byDay != 0 ? byDay : a.order.compareTo(b.order);
      });
      return list;
    });
  }

  Stream<List<PromptItem>> watchPrompts() {
    return _c('journal_prompts').snapshots().map((s) => s.docs.map((d) {
          final data = d.data();
          return PromptItem(
            id: d.id,
            category: PromptCategory.fromValue(data['category'] as String?),
            text: (data['text'] as String?) ?? '',
            status: ContentStatus.fromValue(data['status'] as String?),
          );
        }).toList());
  }

  Stream<List<QuoteItem>> watchQuotes() {
    return _c('quotes').snapshots().map((s) => s.docs.map((d) {
          final data = d.data();
          return QuoteItem(
            id: d.id,
            text: (data['text'] as String?) ?? '',
            author: (data['author'] as String?) ?? 'Unknown',
            category: (data['category'] as String?) ?? 'General',
            status: ContentStatus.fromValue(data['status'] as String?),
          );
        }).toList());
  }

  Stream<List<FaqItem>> watchFaqs() {
    return _c(ContentPaths.faqs).snapshots().map((s) {
      final list = s.docs.map((d) {
        final data = d.data();
        return FaqItem(
          id: d.id,
          question: (data[ContentKeys.question] as String?) ?? '',
          answer: (data[ContentKeys.answer] as String?) ?? '',
          order: (data[ContentKeys.order] as num?)?.toInt() ?? 0,
          status: ContentStatus.fromValue(data[ContentKeys.status] as String?),
        );
      }).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  /// A single admin-editable content document (e.g. `app_config/terms`).
  Stream<ContentPage> watchContentPage(String docId) {
    return _c(ContentPaths.appConfig).doc(docId).snapshots().map((doc) {
      final data = doc.data() ?? const <String, dynamic>{};
      return ContentPage(
        title: (data[ContentKeys.title] as String?) ?? '',
        body: (data[ContentKeys.body] as String?) ?? '',
      );
    });
  }

  Stream<List<AdminNotificationItem>> watchNotifications() {
    return _c('notifications').snapshots().map((s) {
      final list = s.docs.map((d) {
        final data = d.data();
        return AdminNotificationItem(
          id: d.id,
          title: (data['title'] as String?) ?? '',
          message: (data['message'] as String?) ?? '',
          type: NotificationType.fromValue(data['type'] as String?),
          audience: NotificationAudience.fromValue(data['audience'] as String?),
          scheduleAt: (data['scheduleAt'] as Timestamp?)?.toDate(),
          status: (data['status'] as String?) ?? 'scheduled',
        );
      }).toList();
      list.sort((a, b) => (b.scheduleAt ?? DateTime(0))
          .compareTo(a.scheduleAt ?? DateTime(0)));
      return list;
    });
  }

  Stream<List<TransactionItem>> watchTransactions() {
    return _c('transactions').snapshots().map((s) {
      final list = s.docs.map((d) {
        final data = d.data();
        return TransactionItem(
          id: d.id,
          userName: (data['userName'] as String?) ?? '',
          plan: (data['plan'] as String?) ?? '',
          amount: (data['amount'] as num?) ?? 0,
          date: (data['date'] as Timestamp?)?.toDate(),
        );
      }).toList();
      list.sort((a, b) =>
          (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
      return list;
    });
  }

  Stream<AppSettings> watchSettings() {
    return _c('app_config').doc('general').snapshots().map((doc) {
      final data = doc.data() ?? const <String, dynamic>{};
      return AppSettings(
        appVersion: (data['appVersion'] as String?) ?? '1.0.0',
        maintenanceMode: (data['maintenanceMode'] as bool?) ?? false,
        defaultLanguage: (data['defaultLanguage'] as String?) ?? 'en',
        supportEmail: (data[ContentKeys.supportEmail] as String?) ?? '',
        supportPhone: (data[ContentKeys.supportPhone] as String?) ?? '',
        supportMessage: (data[ContentKeys.supportMessage] as String?) ?? '',
        privacyUrl: (data['privacyUrl'] as String?) ?? '',
        termsUrl: (data['termsUrl'] as String?) ?? '',
      );
    });
  }

  // ---- Analytics / subscriptions ----

  Future<AnalyticsSummary> getAnalytics() async {
    try {
      final total = await _count(_users);
      final premium =
          await _count(_users.where('subscription', isEqualTo: 'premium'));
      final results = await Future.wait([
        _count(_users.where('updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfToday))),
        _count(_users.where('updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfMonth))),
        _count(_db.collectionGroup('journal_entries')),
        _count(_db.collectionGroup('ai_conversations')),
      ]);
      final avgSnap =
          await _users.aggregate(average('recoveryScore')).get();
      return AnalyticsSummary(
        dailyActiveUsers: results[0],
        monthlyActiveUsers: results[1],
        averageRecoveryScore: avgSnap.getAverage('recoveryScore') ?? 0,
        journalCount: results[2],
        aiUsage: results[3],
        conversionRate: total == 0 ? 0 : premium / total,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load analytics.', code: e.code);
    }
  }

  Future<SubscriptionSummary> getSubscriptionSummary() async {
    try {
      final total = await _count(_users);
      final results = await Future.wait([
        _count(_users.where('subscription', isEqualTo: 'premium')),
        _count(_users.where('trialStatus', isEqualTo: 'active')),
        _count(_users.where('trialStatus', isEqualTo: 'expired')),
      ]);
      final revenueSnap = await _c('transactions').aggregate(sum('amount')).get();
      return SubscriptionSummary(
        premium: results[0],
        trial: results[1],
        expired: results[2],
        revenue: revenueSnap.getSum('amount') ?? 0,
        conversionRate: total == 0 ? 0 : results[0] / total,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load subscriptions.', code: e.code);
    }
  }

  // ---- Generic writes ----

  Future<String> createDoc(String collection, Map<String, dynamic> data) async {
    try {
      final ref = await _c(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create.', code: e.code);
    }
  }

  Future<void> setDoc(
      String collection, String id, Map<String, dynamic> data) async {
    try {
      await _c(collection).doc(id).set(
        {...data, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save.', code: e.code);
    }
  }

  Future<void> deleteDoc(String collection, String id) async {
    try {
      await _c(collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete.', code: e.code);
    }
  }
}
