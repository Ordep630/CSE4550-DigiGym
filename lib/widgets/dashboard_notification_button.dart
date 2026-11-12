import 'package:flutter/material.dart';

/// A notification affordance that requires a real action from its caller.
class DashboardNotificationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isPreview;

  const DashboardNotificationButton({
    super.key,
    required this.onPressed,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: 48,
      child: Material(
        type: MaterialType.transparency,
        child: IconButton(
          onPressed: onPressed,
          tooltip: isPreview
              ? 'Notifications — development preview'
              : 'Notifications',
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          style: ButtonStyle(
            shape: const WidgetStatePropertyAll(CircleBorder()),
            overlayColor: WidgetStatePropertyAll(
              colors.primary.withValues(alpha: 0.12),
            ),
          ),
          icon: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.10),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x9634413D), Color(0x66151D1A)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 24,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
