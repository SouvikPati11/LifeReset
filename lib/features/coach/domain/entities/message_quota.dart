/// Raw usage counter read from `users/{uid}/private/ai_usage` (server-managed).
class MessageUsage {
  const MessageUsage({required this.used, required this.resetsAt});

  final int used;
  final DateTime resetsAt;

  factory MessageUsage.initial() =>
      MessageUsage(used: 0, resetsAt: MessageQuota._nextMidnight());
}

/// The user's daily AI-message allowance.
///
/// Free trial: [freeDailyLimit] messages/day. Premium: unlimited ([limit] null).
class MessageQuota {
  const MessageQuota({
    required this.used,
    required this.limit,
    required this.resetsAt,
    required this.isPremium,
    this.trialDaysLeft,
  });

  static const int freeDailyLimit = 30;

  final int used;

  /// Daily limit, or `null` when unlimited (premium).
  final int? limit;
  final DateTime resetsAt;
  final bool isPremium;
  final int? trialDaysLeft;

  int? get remaining => limit == null ? null : (limit! - used).clamp(0, limit!);

  bool get isReached => limit != null && used >= limit!;

  factory MessageQuota.initial() => MessageQuota(
        used: 0,
        limit: freeDailyLimit,
        resetsAt: _nextMidnight(),
        isPremium: false,
        trialDaysLeft: null,
      );

  /// Builds a quota from raw [usage] and the user's plan.
  factory MessageQuota.from({
    required MessageUsage usage,
    required bool isPremium,
    int? trialDaysLeft,
  }) {
    return MessageQuota(
      used: usage.used,
      limit: isPremium ? null : freeDailyLimit,
      resetsAt: usage.resetsAt,
      isPremium: isPremium,
      trialDaysLeft: trialDaysLeft,
    );
  }

  static DateTime _nextMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }
}
