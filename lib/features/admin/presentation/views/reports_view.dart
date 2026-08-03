import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

/// Reports section.
///
/// Reports are assembled from live Firestore data and exported as CSV
/// (copied to the clipboard — no external dependency required) and can be
/// previewed in-app as a formatted, print-ready sheet.
class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  static String _escape(Object? value) {
    final s = '${value ?? ''}';
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _toCsv(List<String> header, List<List<Object?>> rows) {
    final buffer = StringBuffer()..writeln(header.map(_escape).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_escape).join(','));
    }
    return buffer.toString();
  }

  ({List<String> header, List<List<Object?>> rows}) _build(
      WidgetRef ref, ReportType type) {
    final df = DateFormat('yyyy-MM-dd');
    switch (type) {
      case ReportType.user:
        final users = ref.read(adminUsersControllerProvider).valueOrNull?.users ??
            const [];
        return (
          header: const ['Name', 'Email', 'Plan', 'Role', 'Status', 'Created'],
          rows: [
            for (final u in users)
              [
                u.name,
                u.email,
                u.plan,
                u.role,
                u.status.label,
                u.createdAt == null ? '' : df.format(u.createdAt!),
              ],
          ],
        );
      case ReportType.recovery:
        final programs = ref.read(programsProvider).valueOrNull ?? const [];
        return (
          header: const ['Program', 'Total Days', 'Users', 'Status'],
          rows: [
            for (final p in programs)
              [p.name, p.totalDays, p.userCount, p.status.label],
          ],
        );
      case ReportType.revenue:
        final txns = ref.read(transactionsProvider).valueOrNull ?? const [];
        return (
          header: const ['User', 'Plan', 'Amount', 'Date'],
          rows: [
            for (final t in txns)
              [
                t.userName,
                t.plan,
                t.amount,
                t.date == null ? '' : df.format(t.date!),
              ],
          ],
        );
      case ReportType.subscription:
        final s = ref.read(subscriptionSummaryProvider).valueOrNull ??
            SubscriptionSummary.empty();
        return (
          header: const ['Metric', 'Value'],
          rows: [
            ['Premium', s.premium],
            ['Trial', s.trial],
            ['Expired', s.expired],
            ['Revenue', s.revenue],
            ['Conversion Rate', '${(s.conversionRate * 100).toStringAsFixed(1)}%'],
          ],
        );
    }
  }

  Future<void> _copyCsv(
      BuildContext context, WidgetRef ref, ReportType type) async {
    final report = _build(ref, type);
    final csv = _toCsv(report.header, report.rows);
    await Clipboard.setData(ClipboardData(text: csv));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard')),
      );
    }
  }

  void _preview(BuildContext context, WidgetRef ref, String title,
      ReportType type) {
    final report = _build(ref, type);
    showDialog<void>(
      context: context,
      builder: (_) => _ReportPreviewDialog(
        title: title,
        header: report.header,
        rows: report.rows,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    const reports = <(String, String, IconData, ReportType)>[
      ('User Report', 'All registered users and their plans', Icons.people_alt_rounded, ReportType.user),
      ('Recovery Report', 'Programs and enrolled users', Icons.self_improvement_rounded, ReportType.recovery),
      ('Revenue Report', 'Recorded transactions', Icons.payments_rounded, ReportType.revenue),
      ('Subscription Report', 'Subscription distribution', Icons.workspace_premium_rounded, ReportType.subscription),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text('Reports', style: textTheme.titleLarge),
        const SizedBox(height: AppSizes.xs),
        Text(
          'Export as CSV (copied to clipboard) or preview a print-ready sheet.',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        for (final r in reports)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: ACard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.5),
                        child: Icon(r.$3,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.$1, style: textTheme.titleSmall),
                            Text(r.$2,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _preview(context, ref, r.$1, r.$4),
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text('Preview'),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      FilledButton.tonalIcon(
                        onPressed: () => _copyCsv(context, ref, r.$4),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Export CSV'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReportPreviewDialog extends StatelessWidget {
  const _ReportPreviewDialog({
    required this.title,
    required this.header,
    required this.rows,
  });

  final String title;
  final List<String> header;
  final List<List<Object?>> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 560,
        child: rows.isEmpty
            ? const Text('No data available for this report.')
            : SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      for (final h in header)
                        DataColumn(
                          label: Text(h,
                              style: textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                    ],
                    rows: [
                      for (final row in rows)
                        DataRow(
                          cells: [
                            for (final cell in row)
                              DataCell(Text('${cell ?? ''}')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
