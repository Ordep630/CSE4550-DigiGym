import 'package:flutter/material.dart';

import '../theme/appearance_controller.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/profile_components.dart';

class AppAppearanceScreen extends StatelessWidget {
  const AppAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppearanceScope.maybeOf(context);
    final mode = controller?.mode ?? ThemeMode.dark;
    return ProfileDestinationScaffold(
      title: 'App Appearance',
      followAppearance: true,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final surfaces = DigiGymSurfaces.of(context);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DashboardGlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final option in [
                      (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark Mode'),
                      (
                        ThemeMode.light,
                        Icons.light_mode_outlined,
                        'Light Mode',
                      ),
                      (
                        ThemeMode.system,
                        Icons.brightness_auto_outlined,
                        'Follow System',
                      ),
                    ]) ...[
                      if (option.$1 != ThemeMode.dark)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                      Semantics(
                        container: true,
                        label: option.$3,
                        button: true,
                        inMutuallyExclusiveGroup: true,
                        selected: mode == option.$1,
                        enabled: controller != null,
                        onTap: controller == null
                            ? null
                            : () => controller.select(option.$1),
                        excludeSemantics: true,
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: controller == null
                                ? null
                                : () => controller.select(option.$1),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Icon(
                                    option.$2,
                                    color: theme.colorScheme.onSurface,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      option.$3,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (mode == option.$1)
                                    Icon(
                                      Icons.check_rounded,
                                      color: surfaces.accent,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (controller?.hasPersistenceError ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Appearance changed for this session. Could not save to this device; DigiGym will retry when you return.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
