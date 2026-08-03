import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

/// Handles all profile write actions (edit info, settings, plan selection).
class ProfileController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  String? get _uid => ref.read(currentUserProvider)?.id;

  Future<bool> saveProfile({
    String? name,
    Gender? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? location,
    String? photoUrl,
  }) async {
    final uid = _uid;
    if (uid == null) return false;
    state = const AsyncLoading();
    final result = await ref.read(updateProfileUseCaseProvider).call(
          uid,
          name: name,
          gender: gender,
          dateOfBirth: dateOfBirth,
          bio: bio,
          location: location,
          photoUrl: photoUrl,
        );
    return _reflect(result);
  }

  Future<bool> updateSettings({
    AppearanceMode? appearance,
    String? language,
    bool? notificationsEnabled,
    bool? remindersEnabled,
  }) async {
    final uid = _uid;
    if (uid == null) return false;
    state = const AsyncLoading();
    final result = await ref.read(updateSettingsUseCaseProvider).call(
          uid,
          appearance: appearance,
          language: language,
          notificationsEnabled: notificationsEnabled,
          remindersEnabled: remindersEnabled,
        );
    return _reflect(result);
  }

  Future<bool> selectPlan(SubscriptionPlan plan) async {
    final uid = _uid;
    if (uid == null) return false;
    state = const AsyncLoading();
    final result = await ref.read(selectPlanUseCaseProvider).call(uid, plan);
    return _reflect(result);
  }

  bool _reflect(Result<void> result) {
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final profileControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileController, void>(
  ProfileController.new,
);
