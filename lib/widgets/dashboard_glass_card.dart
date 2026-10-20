import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// Layered glass without per-card backdrop filtering or animation.
class DashboardGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const DashboardGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(
      Radius.circular(DigiGymDashboardTheme.cardRadius),
    );
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x38000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: CustomPaint(
            foregroundPainter: const _GlassEdgePainter(),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xF23B474A),
                    Color(0xEE192123),
                    Color(0xF00F1618),
                    Color(0xF0222D2F),
                  ],
                  stops: [0, 0.28, 0.72, 1],
                ),
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.85, -1.15),
                    radius: 1.1,
                    colors: [
                      Color(0x20FFFFFF),
                      Color(0x06FFFFFF),
                      Color(0x00FFFFFF),
                    ],
                    stops: [0, 0.35, 1],
                  ),
                ),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassEdgePainter extends CustomPainter {
  const _GlassEdgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x70D5E1DF),
          Color(0x26D5E1DF),
          Color(0x05D5E1DF),
          Color(0x12D5E1DF),
          Color(0x38D5E1DF),
        ],
        stops: [0, 0.16, 0.48, 0.76, 1],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(DigiGymDashboardTheme.cardRadius - 0.5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GlassEdgePainter oldDelegate) => false;
}

/// Shared illuminated icon well used by dashboard cards, never the navbar.
class DashboardIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final bool luminous;

  const DashboardIconBadge({
    super.key,
    required this.icon,
    this.size = 46,
    this.color,
    this.luminous = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
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
              accent.withValues(alpha: luminous ? 0.20 : 0.12),
              const Color(0xFF14231C),
            ),
            Color.alphaBlend(
              accent.withValues(alpha: 0.06),
              const Color(0xFF14231C),
            ),
            const Color(0xFF0E1916),
          ],
          stops: const [0, 0.4, 1],
        ),
        boxShadow: luminous
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  blurRadius: 17,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Color(0x45000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        foregroundPainter: _IconRimPainter(accent, luminous),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment(-0.55, -0.8),
              radius: 0.95,
              colors: [Color(0x24FFFFFF), Color(0x00FFFFFF), Color(0x28000000)],
              stops: [0, 0.5, 1],
            ),
          ),
          child: Icon(icon, size: size * 0.52, color: accent),
        ),
      ),
    );
  }
}

class _IconRimPainter extends CustomPainter {
  final Color accent;
  final bool luminous;

  const _IconRimPainter(this.accent, this.luminous);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final strength = luminous ? 1.0 : 0.35;
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
      accent != oldDelegate.accent || luminous != oldDelegate.luminous;
}
