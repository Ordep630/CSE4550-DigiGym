import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// Two same-color copies follow the actual glyph alpha: a tight luminous core
/// and a restrained outer halo. The caller paints its sharp foreground last.
class DigiGymGlyphGlow extends StatelessWidget {
  final Widget child;
  final double intensity;
  const DigiGymGlyphGlow({super.key, required this.child, this.intensity = 1})
    : assert(intensity >= 0 && intensity <= 1);

  @override
  Widget build(BuildContext context) {
    final surfaces = DigiGymSurfaces.of(context);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (final layer in [
              (surfaces.iconOuterSigma, surfaces.iconOuterOpacity),
              (surfaces.iconCoreSigma, surfaces.iconCoreOpacity),
            ])
              Opacity(
                opacity: layer.$2 * intensity,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: layer.$1,
                    sigmaY: layer.$1,
                  ),
                  child: Center(child: child),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A narrow neutral light core inside the existing glyph alpha. Eroding the
/// copied silhouette leaves the original green edges and sharp foreground intact.
/// This uses the same built-in image-filter pipeline as the surrounding halos.
class DigiGymGlyphHighlight extends StatelessWidget {
  final Widget child;
  final double intensity;
  const DigiGymGlyphHighlight({
    super.key,
    required this.child,
    this.intensity = 1,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = DigiGymSurfaces.of(context);
    final strength = surfaces.iconStrokeHighlight * intensity;
    if (strength == 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Opacity(
          opacity: strength,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: ImageFiltered(
              imageFilter: ImageFilter.erode(
                radiusX: surfaces.iconHighlightInset,
                radiusY: surfaces.iconHighlightInset,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Adds light-only stroke illumination without changing intrinsic geometry.
class DigiGymIlluminatedGlyph extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final double intensity;
  const DigiGymIlluminatedGlyph({
    super.key,
    required this.child,
    this.enabled = true,
    this.intensity = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled ||
        intensity == 0 ||
        Theme.of(context).brightness == Brightness.dark) {
      return child;
    }
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DigiGymGlyphGlow(intensity: intensity, child: child),
        ),
        child,
        Positioned.fill(
          child: DigiGymGlyphHighlight(intensity: intensity, child: child),
        ),
      ],
    );
  }
}

/// A sharp decorative glyph with theme-appropriate illumination. Dark mode
/// retains its approved borderless wash; light mode follows the glyph strokes.
/// The fixed slot preserves card alignment; decoration never intercepts taps.
class SoftGlowIcon extends StatelessWidget {
  static const warmAmber = Color(0xFFFFD35B);

  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final double glowIntensity;

  /// Optional glyph-shaped separation shadow; ignored by the dark renderer.
  final Shadow? lightShadow;

  const SoftGlowIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 32,
    this.iconSize,
    this.glowIntensity = .82,
    this.lightShadow,
  }) : assert(glowIntensity >= 0 && glowIntensity <= 1);

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      final glyph = DigiGymIlluminatedGlyph(
        intensity: glowIntensity,
        child: Icon(icon, size: iconSize ?? size * .64, color: color),
      );
      return IgnorePointer(
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: lightShadow == null
                  ? glyph
                  : Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Center(
                            // Paint only the native glyph shadow, once, behind
                            // the existing illumination and unchanged yellow.
                            child: Icon(
                              icon,
                              size: iconSize ?? size * .64,
                              color: Colors.transparent,
                              shadows: [lightShadow!],
                            ),
                          ),
                        ),
                        glyph,
                      ],
                    ),
            ),
          ),
        ),
      );
    }
    final strength = DigiGymSurfaces.of(context).glowIntensity;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: .5,
                colors: [
                  color.withValues(alpha: .16 * strength),
                  color.withValues(alpha: .09 * strength),
                  color.withValues(alpha: .025 * strength),
                  color.withValues(alpha: 0),
                ],
                stops: const [0, .45, .8, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    alpha: .09 * glowIntensity * strength,
                  ),
                  blurRadius: size * .4,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: iconSize ?? size * .64,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withValues(
                      alpha: .22 * glowIntensity * strength,
                    ),
                    blurRadius: 6,
                  ),
                  Shadow(
                    color: color.withValues(
                      alpha: .08 * glowIntensity * strength,
                    ),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
