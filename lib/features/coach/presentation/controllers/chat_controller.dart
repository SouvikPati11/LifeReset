import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/coach_reply.dart';
import '../providers/coach_providers.dart';

/// Transient UI state for a single chat session.
class ChatUiState {
  const ChatUiState({
    this.isTyping = false,
    this.failedText,
    this.limitReached = false,
    this.crisisActive = false,
  });

  /// True while awaiting the AI reply (drives the typing indicator).
  final bool isTyping;

  /// Text of a message whose reply failed, available to retry.
  final String? failedText;

  /// True when today's free message limit is reached.
  final bool limitReached;

  /// True when the last exchange hit the crisis-safety path.
  final bool crisisActive;
}

/// Controls sending, retrying and the typing state for one conversation.
///
/// Messages themselves are streamed from Firestore (optimistic, via pending
/// writes); this controller only owns the ephemeral send state.
class ChatController extends AutoDisposeFamilyNotifier<ChatUiState, String> {
  @override
  ChatUiState build(String conversationId) => const ChatUiState();

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isTyping) return;
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;

    state = const ChatUiState(isTyping: true);
    final context = await ref.read(coachContextProvider.future);
    final history = ref.read(messagesProvider(arg)).valueOrNull ?? const [];

    final result = await ref.read(sendCoachMessageUseCaseProvider).call(
          uid: uid,
          conversationId: arg,
          text: trimmed,
          context: context,
          history: history,
        );
    _handle(result, trimmed);
  }

  Future<void> retry() async {
    final text = state.failedText;
    if (text == null || state.isTyping) return;
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;

    state = const ChatUiState(isTyping: true);
    final context = await ref.read(coachContextProvider.future);
    final history = ref.read(messagesProvider(arg)).valueOrNull ?? const [];

    final result = await ref.read(retryCoachReplyUseCaseProvider).call(
          uid: uid,
          conversationId: arg,
          text: text,
          context: context,
          history: history,
        );
    _handle(result, text);
  }

  void dismissCrisis() => state = const ChatUiState();

  void _handle(Result<CoachReply> result, String text) {
    result.when(
      success: (reply) {
        state = ChatUiState(crisisActive: reply.isCrisis);
      },
      failure: (failure) {
        if (failure is ServerFailure && failure.code == 'resource-exhausted') {
          state = const ChatUiState(limitReached: true);
        } else {
          state = ChatUiState(failedText: text);
        }
      },
    );
  }
}

final chatControllerProvider = NotifierProvider.autoDispose
    .family<ChatController, ChatUiState, String>(ChatController.new);
