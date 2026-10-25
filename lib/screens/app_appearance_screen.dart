import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/profile_components.dart';

/// The app currently supports one appearance; no preference state is needed yet.
class AppAppearanceScreen extends StatelessWidget {
  const AppAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) => ProfileDestinationScaffold(
    title: 'App Appearance',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DashboardGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Semantics(
                container: true,
                label: 'Dark Mode, selected',
                enabled: true,
                selected: true,
                excludeSemantics: true,
                child: const _AppearanceOption(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  selected: true,
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              Semantics(
                container: true,
                label: 'Light Mode, Coming Soon, unavailable',
                enabled: false,
                excludeSemantics: true,
                child: const _AppearanceOption(
                  icon: Icons.light_mode_outlined,
                  label: 'Light Mode',
                  selected: false,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AppearanceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _AppearanceOption({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? DigiGymDarkColors.primaryText
        : DigiGymDarkColors.secondaryText.withValues(alpha: .55);
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 16, color: color)),
                if (!selected)
                  Text(
                    'Coming Soon',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
              ],
            ),
          ),
          if (selected)
            const Icon(
              Icons.check_rounded,
              color: DigiGymDarkColors.electricGreen,
            ),
        ],
      ),
    );
  }
}
