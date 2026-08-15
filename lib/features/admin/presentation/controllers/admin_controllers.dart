import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../domain/entities/admin_models.dart';
import '../providers/admin_providers.dart';

/// Shared write controller for all Admin CRUD (create / update / delete).
///
/// Every successful write is recorded in the append-only audit trail
/// (`audit_logs`) so administrator actions are traceable. Audit writes are
/// fire-and-forget: a failure to log never fails or blocks the primary write.
class AdminWriteController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> create(String collection, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result =
        await ref.read(adminRepositoryProvider).createDoc(collection, data);
    return result.when(
      success: (id) {
        state = const AsyncData(null);
        _audit('create', collection, id, data.keys.toList());
        return id;
      },
      failure: (f) {
        state = AsyncError(f, StackTrace.current);
        return null;
      },
    );
  }

  Future<bool> save(
      String collection, String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result =
        await ref.read(adminRepositoryProvider).setDoc(collection, id, data);
    final ok = _reflect(result);
    if (ok) _audit('update', collection, id, data.keys.toList());
    return ok;
  }

  Future<bool> remove(String collection, String id) async {
    state = const AsyncLoading();
    final result =
        await ref.read(adminRepositoryProvider).deleteDoc(collection, id);
    final ok = _reflect(result);
    if (ok) _audit('delete', collection, id, const []);
    return ok;
  }

  /// Records one audit entry for the acting admin. Never throws.
  void _audit(
      String action, String module, String? targetId, List<String> fields) {
    final actor = ref.read(userProfileProvider).valueOrNull;
    if (actor == null) return;
    // Fire-and-forget; audit must not affect the primary operation.
    ref.read(adminRepositoryProvider).logAdminAction(
          actorUid: actor.uid,
          actorEmail: actor.email,
          action: action,
          module: module,
          targetId: targetId,
          fields: fields,
        );
  }

  bool _reflect(Result<void> result) {
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
    );
  }
}

final adminWriteControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminWriteController, void>(
  AdminWriteController.new,
);

/// Paginated users list state.
class AdminUsersState {
  const AdminUsersState({
    required this.users,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<AdminUser> users;
  final bool hasMore;
  final bool loadingMore;

  AdminUsersState copyWith({
    List<AdminUser>? users,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      AdminUsersState(
        users: users ?? this.users,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class AdminUsersController extends AutoDisposeAsyncNotifier<AdminUsersState> {
  static const int _pageSize = 15;

  @override
  Future<AdminUsersState> build() async {
    final result =
        await ref.read(adminRepositoryProvider).fetchUsersPage(limit: _pageSize);
    return result.when(
      success: (page) =>
          AdminUsersState(users: page.users, hasMore: page.hasMore),
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    final before = current.users.isEmpty ? null : current.users.last.createdAt;
    final result = await ref
        .read(adminRepositoryProvider)
        .fetchUsersPage(before: before, limit: _pageSize);
    result.when(
      success: (page) {
        state = AsyncData(AdminUsersState(
          users: [...current.users, ...page.users],
          hasMore: page.hasMore,
        ));
      },
      failure: (_) {
        state = AsyncData(current.copyWith(loadingMore: false));
      },
    );
  }
}

final adminUsersControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminUsersController, AdminUsersState>(
  AdminUsersController.new,
);
