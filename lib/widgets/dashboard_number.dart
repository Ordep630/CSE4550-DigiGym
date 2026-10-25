import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// Readable units and accessible text around selectively dotted numerals.
class DashboardNumber extends StatelessWidget {
  final String value;
  final double fontSize;
  final double lineHeight;
  final double? unitFontSize;
  final bool dotted;
  final Color? color;
  final bool fitToWidth;

  const DashboardNumber({
    super.key,
    required this.value,
    this.fontSize = 28,
    this.lineHeight = 1.2,
    this.unitFontSize,
    this.dotted = true,
    this.color,
    this.fitToWidth = false,
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
      child: _fitNumber(
        context,
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: number,
                style: TextStyle(
                  fontFamily: dotted
                      ? DigiGymDashboardTheme.numberFont
                      : DigiGymDashboardTheme.textFont,
                  fontSize: fontSize,
                  height: lineHeight,
                  fontWeight: FontWeight.w600,
                  fontVariations: dotted
                      ? const [
                          FontVariation('ROND', 100),
                          FontVariation('wght', 840),
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
                  fontSize: unitFontSize ?? fontSize * 0.53,
                  color: foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fitNumber(BuildContext context, Widget text) {
    if (!fitToWidth) return text;
    // Longer imperial values stay on one line without changing the card's
    // existing number/label line boxes. Accessible text keeps a larger box.
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.textScalerOf(context)
            .scale((fontSize * lineHeight).floorToDouble()),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: text,
      ),
    );
  }
}
