import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/admin_models.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl extends BaseRepository implements AdminRepository {
  AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<Result<AdminStats>> getStats() => guard(() => _remote.getStats());

  @override
  Future<Result<List<ActivityPoint>>> getSignupActivity({int days = 7}) =>
      guard(() => _remote.getSignupActivity(days: days));

  @override
  Future<Result<List<AdminUser>>> getRecentUsers({int limit = 5}) =>
      guard(() => _remote.getRecentUsers(limit: limit));

  @override
  Future<Result<List<TopProgram>>> getTopPrograms({int limit = 3}) =>
      guard(() => _remote.getTopPrograms(limit: limit));

  @override
  Future<Result<List<SystemService>>> getSystemStatus() =>
      guard(() => _remote.getSystemStatus());

  @override
  Future<Result<List<ProblemDistribution>>> getProblemDistribution() =>
      guard(() => _remote.getProblemDistribution());

  @override
  Future<Result<AdminUsersPage>> fetchUsersPage(
          {DateTime? before, int limit = 15}) =>
      guard(() => _remote.fetchUsersPage(before: before, limit: limit));

  @override
  Stream<List<ProgramItem>> watchPrograms() => _remote.watchPrograms();

  @override
  Stream<List<ProgramTaskItem>> watchTasks(String programId) =>
      _remote.watchTasks(programId);

  @override
  Stream<List<PromptItem>> watchPrompts() => _remote.watchPrompts();

  @override
  Stream<List<QuoteItem>> watchQuotes() => _remote.watchQuotes();

  @override
  Stream<List<FaqItem>> watchFaqs() => _remote.watchFaqs();

  @override
  Stream<ContentPage> watchContentPage(String docId) =>
      _remote.watchContentPage(docId);

  @override
  Stream<List<AdminNotificationItem>> watchNotifications() =>
      _remote.watchNotifications();

  @override
  Stream<List<TransactionItem>> watchTransactions() =>
      _remote.watchTransactions();

  @override
  Stream<AppSettings> watchSettings() => _remote.watchSettings();

  @override
  Future<Result<AnalyticsSummary>> getAnalytics() =>
      guard(() => _remote.getAnalytics());

  @override
  Future<Result<SubscriptionSummary>> getSubscriptionSummary() =>
      guard(() => _remote.getSubscriptionSummary());

  @override
  Future<Result<String>> createDoc(String collection, Map<String, dynamic> data) =>
      guard(() => _remote.createDoc(collection, data));

  @override
  Future<Result<void>> setDoc(
          String collection, String id, Map<String, dynamic> data) =>
      guard(() => _remote.setDoc(collection, id, data));

  @override
  Future<Result<void>> deleteDoc(String collection, String id) =>
      guard(() => _remote.deleteDoc(collection, id));
}
