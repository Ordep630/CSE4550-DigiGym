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
                    Color(0xF2333E41),
                    Color(0xED1A2325),
                    Color(0xF213191B),
                    Color(0xF0242D2F),
                  ],
                  stops: [0, 0.38, 0.75, 1],
                ),
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.9, -1.3),
                    radius: 1.7,
                    colors: [Color(0x13FFFFFF), Color(0x00FFFFFF)],
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
      ..strokeWidth = 1
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x55D5E1DF),
          Color(0x12D5E1DF),
          Color(0x0AD5E1DF),
          Color(0x33D5E1DF),
        ],
        stops: [0, 0.35, 0.65, 1],
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
          center: const Alignment(-0.35, -0.5),
          radius: 1.1,
          colors: [
            accent.withValues(alpha: luminous ? 0.38 : 0.16),
            const Color(0xFF172523),
          ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: luminous ? 0.5 : 0.12),
          width: 0.8,
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
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x20FFFFFF), Color(0x00FFFFFF), Color(0x28000000)],
            stops: [0, 0.45, 1],
          ),
        ),
        child: Icon(icon, size: size * 0.52, color: accent),
      ),
    );
  }
}
