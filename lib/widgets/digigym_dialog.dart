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
  final bool translucentSurface;
  const DigiGymDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.translucentSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    final contentTheme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.resolve(Theme.of(context)),
    );
    final base = translucentSurface
        ? DigiGymDashboardTheme.bmiDialog(contentTheme)
        : contentTheme;
    final surfaces = base.extension<DigiGymSurfaces>()!;
    final theme = base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: surfaces.accent),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: surfaces.accent,
          foregroundColor: surfaces.onAccent,
          minimumSize: const Size(48, 48),
        ),
      ),
      iconTheme: base.iconTheme.copyWith(color: surfaces.accent),
      textSelectionTheme: base.textSelectionTheme.copyWith(
        cursorColor: surfaces.accent,
        selectionColor: surfaces.accent.withValues(alpha: .24),
        selectionHandleColor: surfaces.accent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: surfaces.accent,
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
          surfaceOpacity: translucentSurface ? surfaces.bmiSurfaceOpacity : 1,
          backdropSigma: translucentSurface ? surfaces.bmiBackdropSigma : 0,
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
