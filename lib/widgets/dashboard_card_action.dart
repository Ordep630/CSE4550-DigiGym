import 'package:flutter/material.dart';

/// Adds accessible actions and ink above existing glass without relayout.
class DashboardCardAction extends StatelessWidget {
  final Widget child;
  final String label;
  final VoidCallback? onTap;
  final double bottomGap;

  const DashboardCardAction({
    super.key,
    required this.child,
    required this.label,
    required this.onTap,
    this.bottomGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            bottom: bottomGap,
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                excludeFromSemantics: true,
                borderRadius: BorderRadius.circular(16),
                overlayColor: WidgetStateProperty.resolveWith(
                  (states) => states.isEmpty
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary
                            .withValues(alpha: .10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
