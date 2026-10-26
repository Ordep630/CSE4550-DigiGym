import 'package:flutter/material.dart';

/// A sharp decorative glyph above a faint, borderless wash and diffuse glow.
/// The fixed slot preserves card alignment; decoration never intercepts taps.
class SoftGlowIcon extends StatelessWidget {
  static const warmAmber = Color(0xFFFFD35B);

  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final double glowIntensity;

  const SoftGlowIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 32,
    this.iconSize,
    this.glowIntensity = .82,
  }) : assert(glowIntensity >= 0 && glowIntensity <= 1);

  @override
  Widget build(BuildContext context) => IgnorePointer(
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
                color.withValues(alpha: .16),
                color.withValues(alpha: .09),
                color.withValues(alpha: .025),
                color.withValues(alpha: 0),
              ],
              stops: const [0, .45, .8, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .09 * glowIntensity),
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
                  color: color.withValues(alpha: .22 * glowIntensity),
                  blurRadius: 6,
                ),
                Shadow(
                  color: color.withValues(alpha: .08 * glowIntensity),
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
