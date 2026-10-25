import 'package:flutter/material.dart';

import 'dashboard_glass_card.dart';

class ProfileInformation extends StatelessWidget {
  final String title;
  final String value;

  const ProfileInformation({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final titleStyle = TextStyle(
          color: dark ? theme.colorScheme.onSurfaceVariant : Colors.grey,
        );
        final valueStyle = TextStyle(
          fontWeight: FontWeight.bold,
          color: dark ? theme.colorScheme.onSurface : null,
        );
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
                  style: theme.textTheme.bodyMedium?.merge(valueStyle),
                ),
              ],
            ),
          );
        }
        return ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: dark ? theme.colorScheme.onSurfaceVariant : Colors.grey,
            ),
          ),
          trailing: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dark ? theme.colorScheme.onSurface : null,
            ),
          ),
        );
      },
    );
    return dark
        ? DashboardGlassCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.zero,
            cornerRadius: 12,
            child: content,
          )
        : Card(margin: const EdgeInsets.only(bottom: 8), child: content);
  }
}
