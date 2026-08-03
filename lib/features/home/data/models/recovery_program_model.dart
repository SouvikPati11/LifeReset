import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/recovery_program.dart';

/// Maps a `programs/{id}` document to [RecoveryProgram].
class RecoveryProgramModel {
  const RecoveryProgramModel._();

  static RecoveryProgram fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return RecoveryProgram(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Breakup Recovery',
      totalDays: (data['totalDays'] as num?)?.toInt() ?? 30,
    );
  }
}
