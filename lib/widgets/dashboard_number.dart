import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_dot_typography.dart';
import 'dot_matrix_text.dart';

/// Readable units and accessible text around selectively dotted numerals.
class DashboardNumber extends StatelessWidget {
  final String value;
  final double fontSize;
  final double lineHeight;
  final double? unitFontSize;
  final bool dotted;
  final Color? color;
  final bool fitToWidth;

  /// Opt-in treatment reserved for the three right-hand dashboard statistics.
  final bool statisticTypography;

  /// Doto weight for the existing reference line metrics and fallback text.
  /// Prominent numeric glyphs use the shared Workout dot-matrix treatment.
  final double dotWeight;

  const DashboardNumber({
    super.key,
    required this.value,
    this.fontSize = 28,
    this.lineHeight = 1.2,
    this.unitFontSize,
    this.dotted = true,
    this.color,
    this.fitToWidth = false,
    this.statisticTypography = false,
    this.dotWeight = 840,
  }) : assert(dotWeight >= 100 && dotWeight <= 900);

  @override
  Widget build(BuildContext context) {
    final parts = RegExp(r'^([0-9][0-9.,:]*)(.*)$').firstMatch(value);
    final number = parts?.group(1) ?? value;
    final unit = parts?.group(2) ?? '';
    final foreground = color ?? Theme.of(context).colorScheme.onSurface;
    final surfaces = DigiGymSurfaces.of(context);
    final scale = dotted ? surfaces.numberScale : 1.0;

    TextSpan digits(double sizeScale, double weightBoost) => TextSpan(
      children: [
        TextSpan(
          text: number,
          style: TextStyle(
            fontFamily: dotted
                ? DigiGymDashboardTheme.numberFont
                : DigiGymDashboardTheme.textFont,
            fontSize: fontSize * sizeScale,
            height: lineHeight / sizeScale,
            fontWeight: FontWeight.w600,
            fontVariations: dotted
                ? [
                    const FontVariation('ROND', 100),
                    FontVariation(
                      'wght',
                      (dotWeight + weightBoost).clamp(100, 900),
                    ),
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
    );

    final text = Text.rich(digits(scale, surfaces.dotoWeightBoost));
    Widget content = _fitNumber(context, text);
    if (dotted && parts != null) {
      final inherited = DefaultTextStyle.of(context);
      final scaler = MediaQuery.textScalerOf(context);
      final percent = unit.trim() == '%';
      final matrix = DotMatrixText.standard(
        text: percent ? '$number%' : number,
        height:
            DigiGymDotTypography.heightForFontSize(fontSize) *
            (statisticTypography
                ? DigiGymDotTypography.statisticHeightScale
                : 1),
        fillRatio: statisticTypography
            ? DigiGymDotTypography.statisticFillRatio
            : DigiGymDotTypography.fillRatio,
        color: statisticTypography ? color ?? surfaces.numeralInk : foreground,
      );
      // Preserve Doto's approved intrinsic line metrics. The existing Workout
      // renderer paints inside that slot without resizing cards or unit text.
      content = Stack(
        alignment: Alignment.centerLeft,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            heightFactor: 1,
            child: Opacity(
              opacity: 0,
              child: _fitNumber(
                context,
                RichText(
                  text: TextSpan(
                    style: inherited.style,
                    children: digits(1, 0).children,
                  ),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                  locale: Localizations.maybeLocaleOf(context),
                  textAlign: inherited.textAlign ?? TextAlign.start,
                  softWrap: inherited.softWrap,
                  overflow: inherited.overflow,
                  maxLines: inherited.maxLines,
                  textWidthBasis: inherited.textWidthBasis,
                  textHeightBehavior: inherited.textHeightBehavior,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (statisticTypography)
                    Transform.scale(
                      scale: DigiGymDotTypography.statisticPaintScale,
                      alignment: Alignment.bottomLeft,
                      child: matrix,
                    )
                  else
                    matrix,
                  if (unit.isNotEmpty && !percent) ...[
                    SizedBox(width: scaler.scale(DigiGymDotTypography.unitGap)),
                    Text(
                      unit.trimLeft(),
                      style: TextStyle(
                        fontFamily: DigiGymDashboardTheme.textFont,
                        fontSize: unitFontSize ?? fontSize * .53,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(label: value, excludeSemantics: true, child: content);
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
