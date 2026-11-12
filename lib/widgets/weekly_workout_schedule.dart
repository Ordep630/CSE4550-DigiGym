import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/workout_schedule_day.dart';
import '../services/workout_scheduling.dart';
import '../theme/digigym_dashboard_theme.dart';
import 'dashboard_glass_card.dart';

/// A date-based view only. Missing input stays unassigned; no plan is invented.
class WeeklyWorkoutSchedule extends StatefulWidget {
  final List<WorkoutScheduleDay> days;
  final VoidCallback? onSeeAll;
  final DateTime Function()? clock;
  final Color? seeAllColor;
  final Color? currentDayColor;
  final Color? scheduledColor;
  final ValueChanged<WorkoutScheduleDay>? onDaySelected;
  final List<WorkoutScheduleDay> Function(DateTime)? daysForWeek;
  final String title;
  final String actionLabel;
  final Key actionKey;
  final bool showAction;

  const WeeklyWorkoutSchedule({
    super.key,
    this.days = const [],
    this.onSeeAll,
    this.clock,
    this.seeAllColor,
    this.currentDayColor,
    this.scheduledColor,
    this.onDaySelected,
    this.daysForWeek,
    this.title = 'Your Week',
    this.actionLabel = 'See All',
    this.actionKey = const ValueKey('dashboard-week-see-all'),
    this.showAction = true,
  });

  /// Calendar arithmetic, rather than 24-hour subtraction, also handles DST.
  static List<DateTime> weekDates(DateTime date) {
    return WorkoutScheduling.weekDates(date);
  }

  @override
  State<WeeklyWorkoutSchedule> createState() => _WeeklyWorkoutScheduleState();
}

class _WeeklyWorkoutScheduleState extends State<WeeklyWorkoutSchedule>
    with WidgetsBindingObserver {
  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _names = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  late DateTime _today;
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh(notify: false);
  }

  void _refresh({bool notify = true}) {
    final now = (widget.clock ?? DateTime.now)().toLocal();
    final date = DateUtils.dateOnly(now);
    if (notify && date != _today) {
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
  void didUpdateWidget(WeeklyWorkoutSchedule oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Also recheck when the parent rebuilds after a tab/profile update.
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
    final dates = WeeklyWorkoutSchedule.weekDates(_today);
    final supplied = {
      for (final day in widget.daysForWeek?.call(_today) ?? widget.days)
        day.date: day,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 20,
                height: 1.25,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            if (widget.showAction)
              TextButton(
                key: widget.actionKey,
                onPressed: widget.onSeeAll,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor:
                      widget.seeAllColor ?? theme.colorScheme.primary,
                  disabledForegroundColor:
                      widget.seeAllColor ?? theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                child: Text(widget.actionLabel),
              ),
          ],
        ),
        const SizedBox(height: 4),
        DashboardGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(7, (i) {
              final date = dates[i];
              final day = supplied[date] ?? WorkoutScheduleDay(date: date);
              return Expanded(
                child: _DayColumn(
                  key: ValueKey(
                    'week-day-${date.toIso8601String().split('T').first}',
                  ),
                  day: day,
                  label: _labels[i],
                  name: _names[i],
                  isToday: date == _today,
                  currentDayColor: widget.currentDayColor,
                  scheduledColor: widget.scheduledColor,
                  onTap: widget.onDaySelected == null
                      ? null
                      : () => widget.onDaySelected!(day),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  final WorkoutScheduleDay day;
  final String label;
  final String name;
  final bool isToday;
  final Color? currentDayColor;
  final Color? scheduledColor;
  final VoidCallback? onTap;

  const _DayColumn({
    super.key,
    required this.day,
    required this.label,
    required this.name,
    required this.isToday,
    this.currentDayColor,
    this.scheduledColor,
    this.onTap,
  });

  static const _workoutNames = {
    ScheduledWorkoutType.upperBody: 'Upper Body',
    ScheduledWorkoutType.lowerBody: 'Lower Body',
    ScheduledWorkoutType.fullBody: 'Full Body',
    ScheduledWorkoutType.cardio: 'Cardio',
    ScheduledWorkoutType.core: 'Core',
    ScheduledWorkoutType.push: 'Push',
    ScheduledWorkoutType.pull: 'Pull',
  };
  static const _icons = {
    ScheduledWorkoutType.upperBody: Icons.fitness_center_outlined,
    ScheduledWorkoutType.lowerBody: Icons.directions_walk_outlined,
    ScheduledWorkoutType.fullBody: Icons.accessibility_new_outlined,
    ScheduledWorkoutType.cardio: Icons.monitor_heart_outlined,
    ScheduledWorkoutType.core: Icons.self_improvement_outlined,
    ScheduledWorkoutType.push: Icons.north_east,
    ScheduledWorkoutType.pull: Icons.south_west,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ringColor = currentDayColor ?? colors.primary;
    final state = day.isRestDay
        ? 'Rest Day'
        : _workoutNames[day.workoutType] ?? 'Unassigned Day';
    final date = day.date.toIso8601String().split('T').first;
    return Semantics(
      label:
          '$name, $date${isToday ? ', Today' : ''}, $state${day.isCompleted ? ', Completed Workout' : ''}',
      selected: isToday,
      button: onTap == null ? null : true,
      onTap: onTap,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(34.0, math.max(0.0, constraints.maxWidth - 6));
          final content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Only a single letter scales down if it exceeds its seventh of
              // the row; columns and full semantic day names always remain.
              SizedBox(
                height: MediaQuery.textScalerOf(context).scale(13) * 1.2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    key: ValueKey('week-label-$date'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      color: isToday
                          ? DigiGymDarkColors.softGreen
                          : colors.onSurfaceVariant,
                      shadows: isToday
                          ? [
                              Shadow(
                                color: DigiGymDarkColors.softGreen.withValues(
                                  alpha: .30,
                                ),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                key: ValueKey('week-badge-$date'),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.onSurface.withValues(alpha: .035),
                  border: Border.all(
                    color: isToday
                        ? ringColor.withValues(alpha: .65)
                        : colors.onSurface.withValues(alpha: .10),
                  ),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: ringColor.withValues(alpha: .09),
                            blurRadius: currentDayColor == null ? 9 : 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: day.isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          size: size * .5,
                          color: colors.primary,
                        )
                      : day.isRestDay
                      ? SizedBox.square(
                          dimension: size * .57,
                          child: CustomPaint(
                            painter: _RestSymbol(colors.onSurfaceVariant),
                          ),
                        )
                      : Icon(
                          _icons[day.workoutType] ?? Icons.remove_rounded,
                          size: size * .5,
                          color: day.workoutType == null
                              ? colors.onSurfaceVariant.withValues(alpha: .5)
                              : scheduledColor ?? colors.onSurfaceVariant,
                        ),
                ),
              ),
            ],
          );
          if (onTap == null) return content;
          return Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: content,
            ),
          );
        },
      ),
    );
  }
}

/// Three small vector Zs, with no emoji/font dependency.
class _RestSymbol extends CustomPainter {
  final Color color;
  const _RestSymbol(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      final x = size.width * (.04 + i * .32);
      final y = size.height * (.47 - i * .16);
      final w = size.width * (.22 + i * .02);
      final h = size.height * (.28 + i * .06);
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + w, y)
          ..lineTo(x, y + h)
          ..lineTo(x + w, y + h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RestSymbol oldDelegate) => color != oldDelegate.color;
}
