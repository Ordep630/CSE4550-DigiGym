import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import 'soft_glow_icon.dart';

/// Layered glass with optional clipped frosting; Home defaults stay unfiltered.
class DashboardGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double cornerRadius;
  final double surfaceOpacity;
  final double backdropSigma;
  final double lightingOpacity;

  const DashboardGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.cornerRadius = DigiGymDashboardTheme.cardRadius,
    this.surfaceOpacity = 1,
    this.backdropSigma = 0,
    this.lightingOpacity = 1,
  }) : assert(surfaceOpacity > 0 && surfaceOpacity <= 1),
       assert(backdropSigma >= 0),
       assert(lightingOpacity >= 0 && lightingOpacity <= 1);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(cornerRadius);
    final surfaces = DigiGymSurfaces.of(context);
    Widget frost(Widget content) => backdropSigma == 0
        ? content
        : BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: backdropSigma,
              sigmaY: backdropSigma,
            ),
            child: content,
          );
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [surfaces.glassShadow],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: frost(
            CustomPaint(
              foregroundPainter: _GlassEdgePainter(
                cornerRadius,
                surfaces.glassEdge,
              ),
              child: DecoratedBox(
                decoration: surfaceOpacity == 1
                    ? surfaces.glass
                    : surfaces.glass.copyWith(
                        gradient: surfaces.glass.gradient?.scale(
                          surfaceOpacity,
                        ),
                      ),
                child: DecoratedBox(
                  decoration: lightingOpacity == 1
                      ? surfaces.glassLighting
                      : surfaces.glassLighting.copyWith(
                          gradient: surfaces.glassLighting.gradient?.scale(
                            lightingOpacity,
                          ),
                        ),
                  child: Padding(padding: padding, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassEdgePainter extends CustomPainter {
  final double cornerRadius;
  final Gradient edge;

  const _GlassEdgePainter(this.cornerRadius, this.edge);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = edge.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius - 0.5)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GlassEdgePainter oldDelegate) =>
      cornerRadius != oldDelegate.cornerRadius || edge != oldDelegate.edge;
}

/// Shared illuminated icon well used by dashboard cards, never the navbar.
class DashboardIconBadge extends StatelessWidget {
  final IconData icon;
  final Widget? child;
  final double size;
  final Color? color;
  final bool luminous;

  const DashboardIconBadge({
    super.key,
    required this.icon,
    this.child,
    this.size = 46,
    this.color,
    this.luminous = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    final surfaces = DigiGymSurfaces.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.65, -0.75),
          radius: 1.25,
          colors: [
            Color.alphaBlend(
              accent.withValues(
                alpha: (luminous ? 0.20 : 0.12) * surfaces.glowIntensity,
              ),
              surfaces.iconWell,
            ),
            Color.alphaBlend(
              accent.withValues(alpha: 0.06 * surfaces.glowIntensity),
              surfaces.iconWell,
            ),
            surfaces.iconWellBottom,
          ],
          stops: const [0, 0.4, 1],
        ),
        boxShadow: luminous
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.2 * surfaces.glowIntensity),
                  blurRadius: 17,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: surfaces.iconShadow,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        foregroundPainter: _IconRimPainter(
          accent,
          luminous,
          surfaces.glowIntensity,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: surfaces.iconLighting,
          ),
          child: child == null
              ? DigiGymIlluminatedGlyph(
                  child: Icon(icon, size: size * 0.52, color: accent),
                )
              : Center(child: child),
        ),
      ),
    );
  }
}

class _IconRimPainter extends CustomPainter {
  final Color accent;
  final bool luminous;
  final double glowIntensity;

  const _IconRimPainter(this.accent, this.luminous, this.glowIntensity);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final strength = (luminous ? 1.0 : 0.35) * glowIntensity;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            accent,
            Colors.white,
            0.4,
          )!.withValues(alpha: 0.9 * strength),
          accent.withValues(alpha: 0.65 * strength),
          accent.withValues(alpha: 0.12 * strength),
          accent.withValues(alpha: 0.55 * strength),
        ],
        stops: const [0, 0.18, 0.65, 1],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(_IconRimPainter oldDelegate) =>
      accent != oldDelegate.accent ||
      luminous != oldDelegate.luminous ||
      glowIntensity != oldDelegate.glowIntensity;
}
