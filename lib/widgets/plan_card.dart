import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const PlanCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: colors.onSurfaceVariant),
      ),
    );
  }
}
