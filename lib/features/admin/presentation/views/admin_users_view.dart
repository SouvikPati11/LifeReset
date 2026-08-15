import 'package:flutter/material.dart';

import '../widgets/admin_shell.dart';

/// Placeholder for administrator-account management (list, activate/deactivate,
/// role, revoke access). Ships in the RBAC pass.
class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminModulePlaceholder(
      icon: Icons.admin_panel_settings_rounded,
      title: 'Admin Users',
      message:
          'Listing, searching and managing administrator access — activate, '
          'deactivate and revoke — arrives in the upcoming Admin Users & Audit '
          'pass.',
    );
  }
}
