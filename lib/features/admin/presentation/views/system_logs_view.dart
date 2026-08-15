import 'package:flutter/material.dart';

import '../widgets/admin_shell.dart';

/// Placeholder for the append-only audit trail of admin actions. Ships in the
/// Admin Users & Audit pass.
class SystemLogsView extends StatelessWidget {
  const SystemLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminModulePlaceholder(
      icon: Icons.receipt_long_rounded,
      title: 'System Logs',
      message:
          'An append-only audit trail of administrator actions — who changed '
          'what, when — arrives in the upcoming Admin Users & Audit pass.',
    );
  }
}
