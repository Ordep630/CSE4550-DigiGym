import 'package:flutter/material.dart';

enum DigiGymLogoLayout { stacked, horizontal }

/// The PNGs share path geometry and green fills. Only the neutral ink changes.
class DigiGymBrandLogo extends StatelessWidget {
  final DigiGymLogoLayout layout;
  final double width;
  final double height;

  const DigiGymBrandLogo({
    super.key,
    required this.layout,
    required this.width,
    required this.height,
  });

  static String assetName(DigiGymLogoLayout layout, Brightness brightness) =>
      'assets/branding/digigym_${layout.name}_${brightness.name}.png';

  static const lightFormAsset =
      'assets/branding/digigym_stacked_light_form.png';
  static const lightFormPadding = 3.0;
  static const dashboardHeight = 48 * 331 / 796 * 1.05;
  static const dashboardWidth = 48 + 10 + dashboardHeight * 862 / 189;

  // Keep the existing form positions when the single stacked logo replaces
  // two independently sized images.
  static double stackedSlotHeight({
    required double dumbbellWidth,
    required double wordmarkWidth,
    required double gap,
  }) => dumbbellWidth * 331 / 796 + gap + wordmarkWidth * 189 / 862;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (layout == DigiGymLogoLayout.stacked && brightness == Brightness.light) {
      // Reserve the same artwork box. The extra pixels belong to the baked
      // shadow and paint just outside it without changing the fit of the logo.
      return SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 228,
            height: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -lightFormPadding,
                  top: -lightFormPadding,
                  right: -lightFormPadding,
                  bottom: -lightFormPadding,
                  child: Image.asset(
                    lightFormAsset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.low,
                    semanticLabel: 'DigiGym',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Image.asset(
      assetName(layout, brightness),
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      filterQuality: FilterQuality.low,
      semanticLabel: 'DigiGym',
    );
  }
}
