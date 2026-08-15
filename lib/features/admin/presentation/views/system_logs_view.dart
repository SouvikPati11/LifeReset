import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

/// Read-only viewer for the append-only admin audit trail (`audit_logs`).
class SystemLogsView extends ConsumerWidget {
  const SystemLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(auditLogsProvider);

    return async.when(
      loading: () => const LoadingView(),
      error: (_, __) => ErrorView(
        title: 'Could not load logs',
        onRetry: () => ref.invalidate(auditLogsProvider),
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      size: 40, color: HomeStyle.inkSoft),
                  const SizedBox(height: AppSizes.sm),
                  Text('No admin actions recorded yet.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: HomeStyle.inkSoft)),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, i) =>
              _LogRow(log: logs[i], colorScheme: colorScheme),
        );
      },
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log, required this.colorScheme});
  final AuditLogEntry log;
  final ColorScheme colorScheme;

  Color get _actionColor => switch (log.action) {
        'create' => const Color(0xFF2E9E63),
        'delete' => colorScheme.error,
        _ => colorScheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final when = log.timestamp == null
        ? 'Just now'
        : DateFormat('MMM d, yyyy · h:mm a').format(log.timestamp!);
    return ACard(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
            decoration: BoxDecoration(
              color: _actionColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Text(log.action.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                    color: _actionColor, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.module}${log.targetId.isEmpty ? '' : ' · ${log.targetId}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (log.fields.isNotEmpty)
                  Text('Fields: ${log.fields.join(', ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  '${log.actorEmail.isEmpty ? log.actorUid : log.actorEmail} · $when',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
