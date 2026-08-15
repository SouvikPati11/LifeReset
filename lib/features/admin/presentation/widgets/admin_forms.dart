import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/content_keys.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import 'admin_widgets.dart';

/// Shows a dialog to create or edit a document, calling the shared write
/// controller. Returns when dismissed.
Future<void> _show(BuildContext context, Widget dialog) =>
    showDialog<void>(context: context, builder: (_) => dialog);

Future<void> showProgramForm(BuildContext context, {ProgramItem? existing}) =>
    _show(context, _ProgramDialog(existing: existing));

Future<void> showTaskForm(BuildContext context, String programId,
        {ProgramTaskItem? existing}) =>
    _show(context, _TaskDialog(programId: programId, existing: existing));

Future<void> showPromptForm(BuildContext context, {PromptItem? existing}) =>
    _show(context, _PromptDialog(existing: existing));

Future<void> showQuoteForm(BuildContext context, {QuoteItem? existing}) =>
    _show(context, _QuoteDialog(existing: existing));

Future<void> showFaqForm(BuildContext context, {FaqItem? existing}) =>
    _show(context, _FaqDialog(existing: existing));

Future<void> showNotificationForm(BuildContext context) =>
    _show(context, const _NotificationDialog());

Future<void> showUserEditDialog(BuildContext context, AdminUser user) =>
    _show(context, _UserDialog(user: user));

/// Common dialog chrome with a save button wired to the write controller.
class _Frame extends ConsumerWidget {
  const _Frame({
    required this.title,
    required this.fields,
    required this.onSave,
  });

  final String title;
  final List<Widget> fields;

  /// Returns true to close the dialog on success.
  final Future<bool> Function() onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(adminWriteControllerProvider).isLoading;
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: fields),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving
              ? null
              : () async {
                  final ok = await onSave();
                  if (ok && context.mounted) Navigator.pop(context);
                },
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}

Widget _field(TextEditingController c, String label, {int maxLines = 1}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );

// ---- Program ----
class _ProgramDialog extends ConsumerStatefulWidget {
  const _ProgramDialog({this.existing});
  final ProgramItem? existing;
  @override
  ConsumerState<_ProgramDialog> createState() => _ProgramDialogState();
}

class _ProgramDialogState extends ConsumerState<_ProgramDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _desc =
      TextEditingController(text: widget.existing?.description ?? '');
  late final _days = TextEditingController(
      text: '${widget.existing?.totalDays ?? 30}');
  late String _icon = widget.existing?.iconKey ?? 'spa';
  late String _color = widget.existing?.colorHex ?? '#7C4DFF';
  late ContentStatus _status = widget.existing?.status ?? ContentStatus.active;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: widget.existing == null ? 'Add Program' : 'Edit Program',
      onSave: () async {
        final data = {
          'name': _name.text.trim(),
          'description': _desc.text.trim(),
          'totalDays': int.tryParse(_days.text) ?? 30,
          'status': _status.value,
          'icon': _icon,
          'color': _color,
          if (widget.existing == null) 'userCount': 0,
          if (widget.existing == null) 'order': 0,
        };
        final c = ref.read(adminWriteControllerProvider.notifier);
        return widget.existing == null
            ? (await c.create('programs', data)) != null
            : c.save('programs', widget.existing!.id, data);
      },
      fields: [
        _field(_name, 'Program Name'),
        _field(_desc, 'Description', maxLines: 3),
        _field(_days, 'Total Days'),
        const SizedBox(height: AppSizes.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Icon', style: Theme.of(context).textTheme.labelMedium),
        ),
        Wrap(
          spacing: AppSizes.sm,
          children: [
            for (final key in kProgramIconKeys)
              InkWell(
                onTap: () => setState(() => _icon = key),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: _icon == key
                      ? hexColor(_color).withValues(alpha: 0.25)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(programIcon(key), size: 18, color: hexColor(_color)),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        _StatusDropdown(
          value: _status,
          onChanged: (v) => setState(() => _status = v),
        ),
      ],
    );
  }
}

// ---- Task ----
class _TaskDialog extends ConsumerStatefulWidget {
  const _TaskDialog({required this.programId, this.existing});
  final String programId;
  final ProgramTaskItem? existing;
  @override
  ConsumerState<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<_TaskDialog> {
  late final _day = TextEditingController(text: '${widget.existing?.day ?? 1}');
  late final _task = TextEditingController(text: widget.existing?.task ?? '');
  late final _motivation =
      TextEditingController(text: widget.existing?.motivation ?? '');
  late final _journal =
      TextEditingController(text: widget.existing?.journalQuestion ?? '');
  late final _mood =
      TextEditingController(text: widget.existing?.moodGoal ?? '');
  late final _ai =
      TextEditingController(text: widget.existing?.aiContext ?? '');
  late final _time = TextEditingController(
      text: '${widget.existing?.estimatedMinutes ?? 5}');
  late final _notif =
      TextEditingController(text: widget.existing?.notificationText ?? '');
  late ContentStatus _status = widget.existing?.status ?? ContentStatus.active;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: widget.existing == null ? 'Add Task' : 'Edit Task',
      onSave: () async {
        final data = {
          'programId': widget.programId,
          'day': int.tryParse(_day.text) ?? 1,
          'order': widget.existing?.order ?? 0,
          'task': _task.text.trim(),
          'motivation': _motivation.text.trim(),
          'journalQuestion': _journal.text.trim(),
          'moodGoal': _mood.text.trim(),
          'aiContext': _ai.text.trim(),
          'estimatedMinutes': int.tryParse(_time.text) ?? 5,
          'notificationText': _notif.text.trim(),
          'status': _status.value,
        };
        final c = ref.read(adminWriteControllerProvider.notifier);
        return widget.existing == null
            ? (await c.create('program_tasks', data)) != null
            : c.save('program_tasks', widget.existing!.id, data);
      },
      fields: [
        _field(_day, 'Day'),
        _field(_task, 'Task'),
        _field(_motivation, 'Motivation', maxLines: 2),
        _field(_journal, 'Journal Question'),
        _field(_mood, 'Mood Goal'),
        _field(_ai, 'AI Context', maxLines: 2),
        _field(_time, 'Estimated Time (minutes)'),
        _field(_notif, 'Notification Text', maxLines: 2),
        _StatusDropdown(
          value: _status,
          onChanged: (v) => setState(() => _status = v),
        ),
      ],
    );
  }
}

// ---- Prompt ----
class _PromptDialog extends ConsumerStatefulWidget {
  const _PromptDialog({this.existing});
  final PromptItem? existing;
  @override
  ConsumerState<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends ConsumerState<_PromptDialog> {
  late final _text = TextEditingController(text: widget.existing?.text ?? '');
  late PromptCategory _cat = widget.existing?.category ?? PromptCategory.healing;
  late ContentStatus _status = widget.existing?.status ?? ContentStatus.active;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: widget.existing == null ? 'Add Prompt' : 'Edit Prompt',
      onSave: () async {
        final data = {
          'text': _text.text.trim(),
          'category': _cat.value,
          'status': _status.value,
        };
        final c = ref.read(adminWriteControllerProvider.notifier);
        return widget.existing == null
            ? (await c.create('journal_prompts', data)) != null
            : c.save('journal_prompts', widget.existing!.id, data);
      },
      fields: [
        _field(_text, 'Prompt', maxLines: 3),
        DropdownButtonFormField<PromptCategory>(
          value: _cat,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [
            for (final c in PromptCategory.values)
              DropdownMenuItem(value: c, child: Text(c.label)),
          ],
          onChanged: (v) => setState(() => _cat = v ?? _cat),
        ),
        const SizedBox(height: AppSizes.sm),
        _StatusDropdown(
          value: _status,
          onChanged: (v) => setState(() => _status = v),
        ),
      ],
    );
  }
}

// ---- Quote ----
class _QuoteDialog extends ConsumerStatefulWidget {
  const _QuoteDialog({this.existing});
  final QuoteItem? existing;
  @override
  ConsumerState<_QuoteDialog> createState() => _QuoteDialogState();
}

class _QuoteDialogState extends ConsumerState<_QuoteDialog> {
  late final _text = TextEditingController(text: widget.existing?.text ?? '');
  late final _author =
      TextEditingController(text: widget.existing?.author ?? '');
  late final _cat =
      TextEditingController(text: widget.existing?.category ?? 'Motivation');
  late ContentStatus _status = widget.existing?.status ?? ContentStatus.active;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: widget.existing == null ? 'Add Quote' : 'Edit Quote',
      onSave: () async {
        final data = {
          'text': _text.text.trim(),
          'author': _author.text.trim(),
          'category': _cat.text.trim(),
          'status': _status.value,
        };
        final c = ref.read(adminWriteControllerProvider.notifier);
        return widget.existing == null
            ? (await c.create('quotes', data)) != null
            : c.save('quotes', widget.existing!.id, data);
      },
      fields: [
        _field(_text, 'Quote', maxLines: 3),
        _field(_author, 'Author'),
        _field(_cat, 'Category'),
        _StatusDropdown(
          value: _status,
          onChanged: (v) => setState(() => _status = v),
        ),
      ],
    );
  }
}

// ---- FAQ ----
class _FaqDialog extends ConsumerStatefulWidget {
  const _FaqDialog({this.existing});
  final FaqItem? existing;
  @override
  ConsumerState<_FaqDialog> createState() => _FaqDialogState();
}

class _FaqDialogState extends ConsumerState<_FaqDialog> {
  late final _question =
      TextEditingController(text: widget.existing?.question ?? '');
  late final _answer =
      TextEditingController(text: widget.existing?.answer ?? '');
  late final _order =
      TextEditingController(text: '${widget.existing?.order ?? 0}');
  late ContentStatus _status = widget.existing?.status ?? ContentStatus.active;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: widget.existing == null ? 'Add FAQ' : 'Edit FAQ',
      onSave: () async {
        final data = {
          ContentKeys.question: _question.text.trim(),
          ContentKeys.answer: _answer.text.trim(),
          ContentKeys.order: int.tryParse(_order.text) ?? 0,
          ContentKeys.status: _status.value,
        };
        final c = ref.read(adminWriteControllerProvider.notifier);
        return widget.existing == null
            ? (await c.create(ContentPaths.faqs, data)) != null
            : c.save(ContentPaths.faqs, widget.existing!.id, data);
      },
      fields: [
        _field(_question, 'Question'),
        _field(_answer, 'Answer', maxLines: 5),
        _field(_order, 'Sort Order'),
        _StatusDropdown(
          value: _status,
          onChanged: (v) => setState(() => _status = v),
        ),
      ],
    );
  }
}

// ---- Notification ----
class _NotificationDialog extends ConsumerStatefulWidget {
  const _NotificationDialog();
  @override
  ConsumerState<_NotificationDialog> createState() =>
      _NotificationDialogState();
}

class _NotificationDialogState extends ConsumerState<_NotificationDialog> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  NotificationType _type = NotificationType.announcement;
  NotificationAudience _audience = NotificationAudience.all;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'New Notification',
      onSave: () async {
        final scheduleAt = DateTime(
            _date.year, _date.month, _date.day, _time.hour, _time.minute);
        final data = {
          'title': _title.text.trim(),
          'message': _message.text.trim(),
          'type': _type.value,
          'audience': _audience.value,
          'scheduleAt': scheduleAt,
          'status': 'scheduled',
        };
        final id =
            await ref.read(adminWriteControllerProvider.notifier)
                .create('notifications', data);
        return id != null;
      },
      fields: [
        _field(_title, 'Title'),
        _field(_message, 'Message', maxLines: 3),
        DropdownButtonFormField<NotificationType>(
          value: _type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final t in NotificationType.values)
              DropdownMenuItem(value: t, child: Text(t.label)),
          ],
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        const SizedBox(height: AppSizes.sm),
        DropdownButtonFormField<NotificationAudience>(
          value: _audience,
          decoration: const InputDecoration(labelText: 'Send To'),
          items: [
            for (final a in NotificationAudience.values)
              DropdownMenuItem(value: a, child: Text(a.label)),
          ],
          onChanged: (v) => setState(() => _audience = v ?? _audience),
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _date = d);
                },
                child: Text('${_date.year}-${_date.month}-${_date.day}'),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final t =
                      await showTimePicker(context: context, initialTime: _time);
                  if (t != null) setState(() => _time = t);
                },
                child: Text(_time.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---- User edit ----
class _UserDialog extends ConsumerStatefulWidget {
  const _UserDialog({required this.user});
  final AdminUser user;
  @override
  ConsumerState<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends ConsumerState<_UserDialog> {
  late final _name = TextEditingController(text: widget.user.name);
  late String _plan = widget.user.plan;
  late String _role = widget.user.role;
  late UserStatus _status = widget.user.status;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Edit User',
      onSave: () => ref.read(adminWriteControllerProvider.notifier).save(
        'users',
        widget.user.uid,
        {
          'name': _name.text.trim(),
          'subscription': _plan,
          'role': _role,
          'status': _status.value,
        },
      ),
      fields: [
        _field(_name, 'Name'),
        DropdownButtonFormField<String>(
          value: _plan,
          decoration: const InputDecoration(labelText: 'Plan'),
          items: const [
            DropdownMenuItem(value: 'free', child: Text('Free')),
            DropdownMenuItem(value: 'premium', child: Text('Premium')),
          ],
          onChanged: (v) => setState(() => _plan = v ?? _plan),
        ),
        const SizedBox(height: AppSizes.sm),
        DropdownButtonFormField<String>(
          value: _role,
          decoration: const InputDecoration(labelText: 'Role'),
          items: const [
            DropdownMenuItem(value: 'user', child: Text('User')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: (v) => setState(() => _role = v ?? _role),
        ),
        const SizedBox(height: AppSizes.sm),
        DropdownButtonFormField<UserStatus>(
          value: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            for (final s in UserStatus.values)
              DropdownMenuItem(value: s, child: Text(s.label)),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final ContentStatus value;
  final ValueChanged<ContentStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ContentStatus>(
      value: value,
      decoration: const InputDecoration(labelText: 'Status'),
      items: [
        for (final s in ContentStatus.values)
          DropdownMenuItem(value: s, child: Text(s.label)),
      ],
      onChanged: (v) => onChanged(v ?? value),
    );
  }
}
