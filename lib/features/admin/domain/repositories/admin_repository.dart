import '../../../../core/utils/result.dart';
import '../entities/admin_models.dart';

/// A page of admin users with a keyset cursor flag.
class AdminUsersPage {
  const AdminUsersPage({required this.users, required this.hasMore});
  final List<AdminUser> users;
  final bool hasMore;
}

/// Contract for the Admin Panel. Typed reads for lists/aggregates; generic
/// writes (the UI builds the payload) to keep CRUD across many collections
/// compact. All writes are admin-only (enforced by Firestore Security Rules).
abstract interface class AdminRepository {
  // Dashboard.
  Future<Result<AdminStats>> getStats();
  Future<Result<List<ActivityPoint>>> getSignupActivity({int days});
  Future<Result<List<AdminUser>>> getRecentUsers({int limit});
  Future<Result<List<TopProgram>>> getTopPrograms({int limit});
  Future<Result<List<SystemService>>> getSystemStatus();

  // Users (paginated).
  Future<Result<AdminUsersPage>> fetchUsersPage({DateTime? before, int limit});

  // Content lists (streamed, cached).
  Stream<List<ProgramItem>> watchPrograms();
  Stream<List<ProgramTaskItem>> watchTasks(String programId);
  Stream<List<PromptItem>> watchPrompts();
  Stream<List<QuoteItem>> watchQuotes();
  Stream<List<AdminNotificationItem>> watchNotifications();
  Stream<List<TransactionItem>> watchTransactions();
  Stream<AppSettings> watchSettings();

  // Analytics / subscriptions.
  Future<Result<AnalyticsSummary>> getAnalytics();
  Future<Result<SubscriptionSummary>> getSubscriptionSummary();

  // Generic writes.
  Future<Result<String>> createDoc(String collection, Map<String, dynamic> data);
  Future<Result<void>> setDoc(String collection, String id, Map<String, dynamic> data);
  Future<Result<void>> deleteDoc(String collection, String id);
}
