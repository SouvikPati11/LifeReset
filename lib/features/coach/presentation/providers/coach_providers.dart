import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../data/datasources/coach_remote_data_source.dart';
import '../../data/repositories/coach_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/coach_context.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message_quota.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/usecases/coach_usecases.dart';

/// Dependency graph for the AI Coach feature.

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

final _coachDataSourceProvider = Provider<CoachRemoteDataSource>((ref) {
  return FirebaseCoachRemoteDataSource(
    FirebaseFirestore.instance,
    ref.watch(firebaseFunctionsProvider),
  );
});

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepositoryImpl(ref.watch(_coachDataSourceProvider));
});

// Use cases.
final _watchConversations = Provider((ref) =>
    WatchConversations(ref.watch(coachRepositoryProvider)));
final _watchMessages =
    Provider((ref) => WatchMessages(ref.watch(coachRepositoryProvider)));
final _watchUsage =
    Provider((ref) => WatchUsage(ref.watch(coachRepositoryProvider)));
final getCoachContextUseCaseProvider =
    Provider((ref) => GetCoachContext(ref.watch(coachRepositoryProvider)));
final createConversationUseCaseProvider =
    Provider((ref) => CreateConversation(ref.watch(coachRepositoryProvider)));
final sendCoachMessageUseCaseProvider =
    Provider((ref) => SendCoachMessage(ref.watch(coachRepositoryProvider)));
final retryCoachReplyUseCaseProvider =
    Provider((ref) => RetryCoachReply(ref.watch(coachRepositoryProvider)));

// Section data.

/// The user's conversations, most recent first.
final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(_watchConversations).call(uid);
});

/// Messages for a conversation (lazy, per conversation id).
final messagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(_watchMessages).call(uid, conversationId);
});

/// The current recovery context (also injected into every AI message).
final coachContextProvider = FutureProvider<CoachContext>((ref) async {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return CoachContext.initial();
  final result = await ref.watch(getCoachContextUseCaseProvider).call(uid);
  return result.when(success: (c) => c, failure: (_) => CoachContext.initial());
});

final _usageProvider = StreamProvider<MessageUsage>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(MessageUsage.initial());
  return ref.watch(_watchUsage).call(uid);
});

/// The daily message quota, derived from usage + the user's plan.
final messageQuotaProvider = Provider<MessageQuota>((ref) {
  final usage = ref.watch(_usageProvider).valueOrNull ?? MessageUsage.initial();
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final isPremium = profile?.subscription.isPremium ?? false;
  return MessageQuota.from(usage: usage, isPremium: isPremium);
});
