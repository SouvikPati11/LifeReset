import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

/// Maps the `users/{uid}` document to a rich [UserProfile].
class UserProfileModel {
  const UserProfileModel._();

  static UserProfile fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String fallbackEmail,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserProfile(
      uid: doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? fallbackEmail,
      photoUrl: data['photoUrl'] as String?,
      gender: Gender.fromValue(data['gender'] as String?),
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      bio: (data['bio'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      language: (data['language'] as String?) ?? 'en',
      appearance: AppearanceMode.fromValue(data['appearance'] as String?),
      notificationsEnabled: (data['notificationsEnabled'] as bool?) ?? true,
      remindersEnabled: (data['remindersEnabled'] as bool?) ?? false,
      plan: SubscriptionPlan.fromValue(data['subscriptionPlan'] as String?),
      trialStatus: TrialStatus.fromValue(data['trialStatus'] as String?),
      trialEndDate: (data['trialEndDate'] as Timestamp?)?.toDate(),
      recoveryScore: (data['recoveryScore'] as num?)?.toInt() ?? 0,
      currentDay: (data['currentDay'] as num?)?.toInt() ?? 1,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      completedTasks: (data['completedTasks'] as List<dynamic>?)?.length ?? 0,
    );
  }
}
