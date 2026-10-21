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
    final content = ListTile(
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
