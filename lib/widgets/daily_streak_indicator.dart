import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// Displays a supplied streak; this widget never calculates or persists one.
class DailyStreakIndicator extends StatelessWidget {
  final int? days;
  final bool unavailable;

  /// Identifies sample data to assistive technology without extra visible text.
  final bool isPreview;

  const DailyStreakIndicator({
    super.key,
    this.days,
    this.isPreview = false,
    this.unavailable = false,
  }) : assert(days == null || days >= 0);

  static const _numberStyle = TextStyle(
    fontFamily: DigiGymDashboardTheme.textFont,
    fontSize: 17,
    height: 1,
    fontWeight: FontWeight.w600,
    color: DigiGymDarkColors.primaryText,
  );

  /// Natural width used by the header to wrap actions without shrinking art.
  static double preferredWidth(
    BuildContext context,
    int? days, {
    bool unavailable = false,
  }) {
    final number = TextPainter(
      text: TextSpan(
        text: unavailable ? '–' : (days ?? 0).toString(),
        style: DefaultTextStyle.of(context).style.merge(_numberStyle),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    )..layout();
    final width =
        22 + MediaQuery.textScalerOf(context).scale(17) + 6 + number.width;
    number.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final colors = Theme.of(context).colorScheme;
    final surfaces = DigiGymSurfaces.of(context);
    return Semantics(
      label: unavailable
          ? 'Workout streak unavailable'
          : days == null
          ? '0-day workout streak. No workout completions recorded; tracking is not available yet.'
          : isPreview
          ? 'Development preview: sample $days-day workout streak'
          : '$days-day workout streak',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: surfaces.streak.copyWith(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 2,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: scaler.scale(17),
              color: surfaces.streakAccent,
            ),
            Text(
              unavailable ? '–' : (days ?? 0).toString(),
              style: _numberStyle.copyWith(
                color: (days ?? 0) == 0
                    ? colors.onSurfaceVariant
                    : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
