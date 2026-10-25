import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// Let enlarged titles wrap instead of clipping inside a fixed toolbar height.
AppBar workoutAppBar(
  BuildContext context, {
  required String title,
  bool showBack = false,
  bool large = false,
  ThemeData? theme,
}) {
  final style = (theme ?? Theme.of(context)).textTheme.titleLarge?.copyWith(
    fontSize: large ? 30 : 20,
    fontWeight: large ? FontWeight.w700 : FontWeight.w600,
    height: 1.2,
  );
  final painter =
      TextPainter(
        text: TextSpan(text: title, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(
        maxWidth: math.max(
          1,
          MediaQuery.sizeOf(context).width - (showBack ? 96 : 40),
        ),
      );
  final height = math.max(kToolbarHeight, painter.height + 16);
  painter.dispose();
  return AppBar(
    automaticallyImplyLeading: showBack,
    leading: showBack
        ? const BackButton(color: DigiGymDarkColors.electricGreen)
        : null,
    titleSpacing: 20,
    toolbarHeight: height,
    titleTextStyle: style,
    title: Text(title),
  );
}
