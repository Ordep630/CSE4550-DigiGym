import 'package:flutter/material.dart';

import 'dashboard_glass_card.dart';
import 'dashboard_number.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool highlightValue;
  final bool embedded;
  final bool dotted;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.highlightValue = false,
    this.embedded = false,
    this.dotted = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final originalSize = embedded && dotted ? 29.0 : 27.0;
    final numberScale = !dotted ? 1.0 : (embedded ? 1.15 : 1.17);
    final content = Row(
      children: [
        DashboardIconBadge(
          icon: icon,
          size: 32,
          color: iconColor,
          luminous: false,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardNumber(
                value: value,
                dotted: dotted,
                fontSize: originalSize * numberScale,
                // Larger glyphs use the existing line box and unit sizing.
                lineHeight: 1.2 / numberScale,
                unitFontSize: originalSize * 0.53,
                color: highlightValue ? theme.colorScheme.primary : null,
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  height: 1.35,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return embedded
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: content,
          )
        : DashboardGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: content,
          );
  }
}
