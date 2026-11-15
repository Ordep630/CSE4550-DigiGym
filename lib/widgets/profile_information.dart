import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_screen_theme.dart';
import '../theme/digigym_workout_theme.dart';
import 'dashboard_glass_card.dart';

class ProfileInformation extends StatelessWidget {
  final String title;
  final String value;
  final bool connected;
  final Color? valueColor;

  const ProfileInformation({
    super.key,
    required this.title,
    required this.value,
    this.connected = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = DigiGymScreenTheme.isLight(context);
    final dark = theme.brightness == Brightness.dark;
    final appAppearance = light || dark;
    final titleStyle = TextStyle(
      color: appAppearance ? theme.colorScheme.onSurfaceVariant : Colors.grey,
    );
    final valueStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: light
          ? switch (valueColor) {
              DigiGymFitnessLevelColors.beginner =>
                DigiGymSurfaces.light.accent,
              DigiGymFitnessLevelColors.intermediate =>
                DigiGymWorkoutTheme.intermediatePlanAccent,
              DigiGymFitnessLevelColors.advanced => theme.colorScheme.error,
              _ => valueColor ?? theme.colorScheme.onSurface,
            }
          : valueColor ?? (dark ? theme.colorScheme.onSurface : null),
    );
    final content = LayoutBuilder(
      builder: (context, constraints) {
        double width(String text, TextStyle? style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.maybeLocaleOf(context),
          )..layout();
          final measured = painter.width;
          painter.dispose();
          return measured;
        }

        // Keep the approved ListTile geometry at ordinary sizes. Long imperial
        // values and accessible text can wrap vertically without being clipped.
        if (width(title, theme.textTheme.bodyLarge?.merge(titleStyle)) +
                width(value, theme.textTheme.bodyMedium?.merge(valueStyle)) +
                48 >
            constraints.maxWidth) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.merge(titleStyle),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.merge(valueStyle),
                ),
              ],
            ),
          );
        }
        return ListTile(
          title: Text(title, style: titleStyle),
          trailing: Text(value, textAlign: TextAlign.right, style: valueStyle),
        );
      },
    );
    if (connected) return content;
    if (!appAppearance) {
      return Card(margin: const EdgeInsets.only(bottom: 8), child: content);
    }
    return DashboardGlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      cornerRadius: 12,
      child: content,
    );
  }
}
