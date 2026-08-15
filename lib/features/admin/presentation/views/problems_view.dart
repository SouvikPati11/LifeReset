import 'package:flutter/material.dart';

import '../widgets/admin_shell.dart';

/// Placeholder for the full read-only Problem analytics module. A live snapshot
/// (the "Users by Problem Category" donut) already ships on the Dashboard.
class ProblemsView extends StatelessWidget {
  const ProblemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminModulePlaceholder(
      icon: Icons.category_rounded,
      title: 'Problem Analytics',
      message:
          'Detailed read-only distribution, trends and user grouping across '
          'recovery areas arrive in a later pass. A live snapshot already '
          'appears on the Dashboard.',
    );
  }
}
