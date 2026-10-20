import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// Readable units and accessible text around selectively dotted numerals.
class DashboardNumber extends StatelessWidget {
  final String value;
  final double fontSize;
  final bool dotted;
  final Color? color;

  const DashboardNumber({
    super.key,
    required this.value,
    this.fontSize = 28,
    this.dotted = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final parts = RegExp(r'^([0-9][0-9.,]*)(.*)$').firstMatch(value);
    final number = parts?.group(1) ?? value;
    final unit = parts?.group(2) ?? '';
    final foreground = color ?? Theme.of(context).colorScheme.onSurface;

    return Semantics(
      label: value,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: number,
              style: TextStyle(
                fontFamily: dotted
                    ? DigiGymDashboardTheme.numberFont
                    : DigiGymDashboardTheme.textFont,
                fontSize: fontSize,
                height: 1.2,
                fontWeight: FontWeight.w600,
                fontVariations: dotted
                    ? const [
                        FontVariation('ROND', 100),
                        FontVariation('wght', 750),
                      ]
                    : null,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: foreground,
              ),
            ),
            TextSpan(
              text: unit,
              style: TextStyle(
                fontFamily: DigiGymDashboardTheme.textFont,
                fontSize: fontSize * 0.53,
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
