import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/workout_schedule_day.dart';
import 'dashboard_glass_card.dart';
import 'dot_matrix_text.dart';

/// Read-only current-month view of the same dated inputs as Your Week.
/// Absence of a record never implies a missed or completed workout.
class MonthlyActivityCalendar extends StatefulWidget {
  final List<WorkoutScheduleDay> days;
  final DateTime Function()? clock;
  final Color? highlightColor;

  const MonthlyActivityCalendar({
    super.key,
    this.days = const [],
    this.clock,
    this.highlightColor,
  });

  static List<DateTime?> monthDates(DateTime date) {
    final local = date.toLocal();
    final first = DateTime(local.year, local.month);
    final length = DateTime(local.year, local.month + 1, 0).day;
    final offset = first.weekday % 7;
    final count = ((offset + length) / 7).ceil() * 7;
    return List.generate(
      count,
      (i) => i < offset || i >= offset + length
          ? null
          : DateTime(local.year, local.month, i - offset + 1),
    );
  }

  @override
  State<MonthlyActivityCalendar> createState() =>
      _MonthlyActivityCalendarState();
}

class _MonthlyActivityCalendarState extends State<MonthlyActivityCalendar>
    with WidgetsBindingObserver {
  static const _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  Timer? _midnight;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh(notify: false);
  }

  void _refresh({bool notify = true}) {
    final now = (widget.clock ?? DateTime.now)().toLocal();
    final date = DateUtils.dateOnly(now);
    if (notify && _today != date) {
      setState(() => _today = date);
    } else {
      _today = date;
    }
    _midnight?.cancel();
    _midnight = Timer(
      DateTime(now.year, now.month, now.day + 1).difference(now),
      _refresh,
    );
  }

  @override
  void didUpdateWidget(MonthlyActivityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refresh(notify: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    } else {
      _midnight?.cancel();
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Monthly Activity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            height: 1.25,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        DashboardGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaler = MediaQuery.textScalerOf(context);
              final stacked =
                  constraints.maxWidth < 280 || scaler.scale(11) > 15.4;
              final date = Semantics(
                label:
                    'Today, ${_monthNames[_today.month - 1]} ${_today.day}, ${_today.year}',
                excludeSemantics: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _months[_today.month - 1],
                      key: const ValueKey('activity-month'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: DotMatrixText(
                        key: const ValueKey('activity-date'),
                        text: '${_today.day}',
                        height: 48,
                        color:
                            widget.highlightColor ?? theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
              final calendar = _calendar(context);
              if (stacked) {
                return Column(
                  children: [date, const SizedBox(height: 16), calendar],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: constraints.maxWidth * .27, child: date),
                  const SizedBox(width: 10),
                  Container(
                    width: .7,
                    height: 66,
                    color: theme.colorScheme.onSurface.withValues(alpha: .09),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: calendar),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _calendar(BuildContext context) {
    final theme = Theme.of(context);
    final dates = MonthlyActivityCalendar.monthDates(_today);
    final supplied = {for (final day in widget.days) day.date: day};
    final cellHeight = math.max(
      20.0,
      MediaQuery.textScalerOf(context).scale(11) * 1.25 + 6,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _weekdays[i],
                      key: ValueKey('month-weekday-$i'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        height: 1.2,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var row = 0; row < dates.length ~/ 7; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: SizedBox(
                    height: cellHeight,
                    child: dates[row * 7 + col] == null
                        ? const SizedBox()
                        : _CalendarDate(
                            date: dates[row * 7 + col]!,
                            today: _today,
                            activity: supplied[dates[row * 7 + col]],
                            monthName: _monthNames[_today.month - 1],
                            highlightColor:
                                widget.highlightColor ??
                                theme.colorScheme.primary,
                          ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _CalendarDate extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final WorkoutScheduleDay? activity;
  final String monthName;
  final Color highlightColor;
  const _CalendarDate({
    required this.date,
    required this.today,
    required this.activity,
    required this.monthName,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final current = date == today;
    final future = date.isAfter(today);
    final record = activity;
    final state =
        record == null ||
            (record.workoutType == null &&
                !record.isRestDay &&
                !record.isCompleted)
        ? 'No activity data'
        : record.isCompleted
        ? 'Completed workout'
        : record.isRestDay
        ? 'Scheduled rest day'
        : record.isMissed
        ? 'Missed scheduled workout'
        : future
        ? 'Future scheduled workout'
        : 'Scheduled workout';
    final indicator = switch (state) {
      'Completed workout' => Icons.circle,
      'Scheduled rest day' => Icons.bedtime_outlined,
      'Missed scheduled workout' => Icons.remove_rounded,
      'Scheduled workout' ||
      'Future scheduled workout' => Icons.circle_outlined,
      _ => null,
    };
    final tone = state == 'Completed workout'
        ? colors.primary
        : state == 'Missed scheduled workout'
        ? colors.error.withValues(alpha: .75)
        : colors.onSurfaceVariant;
    return Semantics(
      key: ValueKey('month-day-${date.toIso8601String().split('T').first}'),
      label:
          '$monthName ${date.day}, ${date.year}${current ? ', Today' : ''}, $state',
      selected: current,
      excludeSemantics: true,
      child: Container(
        key: ValueKey(
          'month-outline-${date.toIso8601String().split('T').first}',
        ),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: current
              ? Border.all(
                  color: highlightColor.withValues(alpha: .45),
                  width: .8,
                )
              : null,
          color: current ? highlightColor.withValues(alpha: .06) : null,
        ),
        // A missing activity indicator must not reserve space below the date.
        // Center the number in the full cell and overlay explicit activity at
        // its bottom edge, independently of the outline and text constraints.
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${date.day}',
                  key: ValueKey(
                    'month-number-${date.toIso8601String().split('T').first}',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 1.15,
                    fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                    color: current
                        ? colors.onSurface
                        : colors.onSurfaceVariant.withValues(
                            alpha: future ? .6 : 1,
                          ),
                  ),
                ),
              ),
            ),
            if (indicator != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: .5,
                height: 4,
                child: Icon(
                  indicator,
                  key: ValueKey('activity-state-${date.day}'),
                  size: 4,
                  color: tone,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
