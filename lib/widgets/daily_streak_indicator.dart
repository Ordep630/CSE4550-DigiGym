import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// Displays a supplied streak; this widget never calculates or persists one.
class DailyStreakIndicator extends StatelessWidget {
  final int? days;

  /// Identifies sample data to assistive technology without extra visible text.
  final bool isPreview;

  const DailyStreakIndicator({super.key, this.days, this.isPreview = false})
    : assert(days == null || days >= 0);

  static const _orange = Color(0xFFFFAA58);
  static const _numberStyle = TextStyle(
    fontFamily: DigiGymDashboardTheme.textFont,
    fontSize: 17,
    height: 1,
    fontWeight: FontWeight.w600,
    color: DigiGymDarkColors.primaryText,
  );

  /// Natural width used by the header to wrap actions without shrinking art.
  static double preferredWidth(BuildContext context, int? days) {
    final number = TextPainter(
      text: TextSpan(
        text: (days ?? 0).toString(),
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
    return Semantics(
      label: days == null
          ? '0-day workout streak. No workout completions recorded; tracking is not available yet.'
          : isPreview
          ? 'Development preview: sample $days-day workout streak'
          : '$days-day workout streak',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _orange.withValues(alpha: 0.30)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xE032302B), Color(0xE619211F), Color(0xE6212723)],
            stops: [0, 0.55, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: _orange.withValues(alpha: 0.11),
              blurRadius: 12,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 2,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: scaler.scale(17),
              color: _orange,
            ),
            Text(
              (days ?? 0).toString(),
              style: _numberStyle.copyWith(
                color: (days ?? 0) == 0
                    ? DigiGymDarkColors.secondaryText
                    : DigiGymDarkColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
