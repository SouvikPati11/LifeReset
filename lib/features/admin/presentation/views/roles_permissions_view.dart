import 'package:flutter/material.dart';

import '../widgets/admin_shell.dart';

/// Placeholder for role-based access control management. Ships in the RBAC pass.
class RolesPermissionsView extends StatelessWidget {
  const RolesPermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminModulePlaceholder(
      icon: Icons.key_rounded,
      title: 'Roles & Permissions',
      message:
          'Role-based access control — administrator roles and their module '
          'permissions — arrives in the upcoming Admin Users & Audit pass.',
    );
  }
}
