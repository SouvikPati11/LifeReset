import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

/// One capability row: what a User vs an Admin may do in a module.
class _Capability {
  const _Capability(this.module, this.user, this.admin);
  final String module;
  final bool user;
  final bool admin;
}

/// The enforced capability matrix for the binary user/admin role model. This is
/// a faithful, read-only reflection of the Firestore Security Rules — it does
/// not introduce a roles/permissions collection or a granular schema. Access is
/// always enforced server-side; this view documents it and shows live counts.
const List<_Capability> _matrix = [
  _Capability('View own recovery data', true, true),
  _Capability('Manage recovery content', false, true),
  _Capability('View admin analytics', false, true),
  _Capability('Manage users & status', false, true),
  _Capability('Grant / revoke admin access', false, true),
  _Capability('View & append audit logs', false, true),
  _Capability('Edit app settings & content', false, true),
];

class RolesPermissionsView extends ConsumerWidget {
  const RolesPermissionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final admins = ref.watch(adminUsersListProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        MetricGrid(
          tiles: [
            MetricTile(
                icon: Icons.shield_rounded,
                value: '${admins.length}',
                label: 'Admins'),
            MetricTile(
                icon: Icons.badge_rounded,
                value: '2',
                label: 'Roles (User, Admin)',
                color: colorScheme.tertiary),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Capabilities by Role', style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('Enforced server-side by Firestore Security Rules.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSizes.md),
              _HeaderRow(textTheme: textTheme, colorScheme: colorScheme),
              const Divider(height: AppSizes.md),
              for (final cap in _matrix) ...[
                _MatrixRow(cap: cap),
                if (cap != _matrix.last) const SizedBox(height: AppSizes.sm),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          'Roles are intentionally a simple, safe user/admin model. Change a '
          'user\'s role from the Admin Users section.',
          style: textTheme.labelSmall?.copyWith(color: HomeStyle.inkSoft),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.textTheme, required this.colorScheme});
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final style = textTheme.labelMedium
        ?.copyWith(fontWeight: FontWeight.w700, color: HomeStyle.inkSoft);
    return Row(
      children: [
        Expanded(child: Text('Capability', style: style)),
        SizedBox(width: 52, child: Text('User', textAlign: TextAlign.center, style: style)),
        SizedBox(width: 52, child: Text('Admin', textAlign: TextAlign.center, style: style)),
      ],
    );
  }
}

class _MatrixRow extends StatelessWidget {
  const _MatrixRow({required this.cap});
  final _Capability cap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(cap.module,
              style: textTheme.bodyMedium, maxLines: 2),
        ),
        SizedBox(width: 52, child: Center(child: _mark(cap.user))),
        SizedBox(width: 52, child: Center(child: _mark(cap.admin))),
      ],
    );
  }

  Widget _mark(bool on) => Icon(
        on ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
        size: 18,
        color: on ? const Color(0xFF2E9E63) : HomeStyle.inkSoft,
      );
}
