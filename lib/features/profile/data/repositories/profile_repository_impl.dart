import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl extends BaseRepository implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Stream<UserProfile> watchProfile(String uid, String email) =>
      _remote.watchProfile(uid, email);

  @override
  Future<Result<void>> updateProfile(
    String uid, {
    String? name,
    Gender? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? location,
    String? photoUrl,
  }) {
    final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender.value,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
    return guard<void>(() => _remote.updateFields(uid, fields));
  }

  @override
  Future<Result<void>> updateSettings(
    String uid, {
    AppearanceMode? appearance,
    String? language,
    bool? notificationsEnabled,
    bool? remindersEnabled,
  }) {
    final fields = <String, dynamic>{
      if (appearance != null) 'appearance': appearance.value,
      if (language != null) 'language': language,
      if (notificationsEnabled != null)
        'notificationsEnabled': notificationsEnabled,
      if (remindersEnabled != null) 'remindersEnabled': remindersEnabled,
    };
    return guard<void>(() => _remote.updateFields(uid, fields));
  }

  @override
  Future<Result<void>> selectPlan(String uid, SubscriptionPlan plan) {
    final fields = <String, dynamic>{
      'subscriptionPlan': plan.value,
      if (plan == SubscriptionPlan.premium) ...{
        'trialStatus': TrialStatus.active.value,
        'trialEndDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: UserProfile.trialLengthDays)),
        ),
      } else ...{
        'trialStatus': TrialStatus.none.value,
      },
    };
    return guard<void>(() => _remote.updateFields(uid, fields));
  }
}
