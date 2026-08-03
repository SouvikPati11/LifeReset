import '../../../../core/constants/app_constants.dart';

/// A recovery program (`programs/{id}`). Version 1: Breakup Recovery.
class RecoveryProgram {
  const RecoveryProgram({
    required this.id,
    required this.title,
    required this.totalDays,
  });

  final String id;
  final String title;
  final int totalDays;

  /// Default 30-day Breakup Recovery program used before the program document
  /// has been provisioned.
  factory RecoveryProgram.defaultProgram() => const RecoveryProgram(
        id: AppConstants.supportedProgram,
        title: 'Breakup Recovery',
        totalDays: 30,
      );
}
