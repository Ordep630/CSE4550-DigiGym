import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import 'dashboard_glass_card.dart';

/// One lightweight glass surface, with scrollable content and wrapping actions.
/// Reuse this surface for app dialogs. It preserves the approved BMI styling
/// without global page/theme changes or additional backdrop filters.
class DigiGymDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  const DigiGymDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final base = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
    final theme = base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: DigiGymDarkColors.softGreen,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DigiGymDarkColors.softGreen,
          foregroundColor: DigiGymDarkColors.graphite,
          minimumSize: const Size(48, 48),
        ),
      ),
      iconTheme: base.iconTheme.copyWith(color: DigiGymDarkColors.softGreen),
      textSelectionTheme: base.textSelectionTheme.copyWith(
        cursorColor: DigiGymDarkColors.softGreen,
        selectionColor: DigiGymDarkColors.softGreen.withValues(alpha: .24),
        selectionHandleColor: DigiGymDarkColors.softGreen,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: DigiGymDarkColors.softGreen,
        ),
      ),
    );
    return Theme(
      data: theme,
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        child: DashboardGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        key: const ValueKey('digigym-dialog-title'),
                        style: theme.textTheme.titleLarge,
                        semanticsLabel: title,
                      ),
                      const SizedBox(height: 16),
                      content,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(alignment: WrapAlignment.end, spacing: 8, children: actions),
            ],
          ),
        ),
      ),
    );
  }
}
