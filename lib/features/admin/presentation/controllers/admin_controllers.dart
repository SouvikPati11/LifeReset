import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/admin_models.dart';
import '../providers/admin_providers.dart';

/// Shared write controller for all Admin CRUD (create / update / delete).
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
    return _reflect(result);
  }

  Future<bool> remove(String collection, String id) async {
    state = const AsyncLoading();
    final result =
        await ref.read(adminRepositoryProvider).deleteDoc(collection, id);
    return _reflect(result);
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
