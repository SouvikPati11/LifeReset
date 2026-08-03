import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/mood_type.dart';
import 'mood_widgets.dart';

/// A month calendar highlighting days with a recorded mood.
class MoodCalendar extends StatefulWidget {
  const MoodCalendar({super.key, required this.moodByDay});

  /// Recorded mood keyed by date (normalized to midnight).
  final Map<DateTime, MoodType> moodByDay;

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int months) {
    setState(() => _month = DateTime(_month.year, _month.month + months));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final firstWeekday = DateTime(_month.year, _month.month).weekday % 7; // Sun=0
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      cells.add(_DayCell(day: day, mood: widget.moodByDay[date]));
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => _shift(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(_month),
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () => _shift(1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        Row(
          children: [
            for (final w in weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, this.mood});

  final int day;
  final MoodType? mood;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$day', style: textTheme.bodySmall),
        const SizedBox(height: 2),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mood == null ? Colors.transparent : moodColor(mood!),
          ),
        ),
      ],
    );
  }
}
