import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import 'digigym_atmospheric_background.dart';
import 'workout_app_bar.dart';

/// Profile destinations share the approved background, typography and toolbar.
/// They are full routes, so only the system safe area is reserved at the bottom.
class ProfileDestinationScaffold extends StatelessWidget {
  final String? title;
  final Widget child;

  const ProfileDestinationScaffold({
    super.key,
    this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
    return Theme(
      data: theme,
      child: DigiGymAtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: title == null
              ? AppBar(
                  leading: const BackButton(
                    color: DigiGymDarkColors.electricGreen,
                  ),
                )
              : workoutAppBar(
                  context,
                  title: title!,
                  showBack: true,
                  theme: theme,
                ),
          body: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final double size;
  final String? name;

  /// Presentation seam for a future profile image; no upload/storage behavior.
  final ImageProvider? image;

  const ProfileAvatar({super.key, this.size = 56, this.name, this.image});

  @override
  Widget build(BuildContext context) {
    // Grapheme clusters preserve accented initials and combined symbols.
    final displayName = name?.trim() ?? '';
    final initial = Padding(
      padding: EdgeInsets.all(size * .16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayName.isEmpty
              ? '?'
              : displayName.characters.first.toUpperCase(),
          style: TextStyle(
            fontFamily: DigiGymDashboardTheme.textFont,
            fontSize: size * .43,
            fontWeight: FontWeight.w600,
            height: 1,
            color: DigiGymDarkColors.primaryText,
          ),
        ),
      ),
    );
    return ExcludeSemantics(
      child: _EmeraldGlassAvatar(
        size: size,
        child: image == null
            ? initial
            : ClipOval(
                child: Image(
                  image: image!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => initial,
                ),
              ),
      ),
    );
  }
}

/// A local reflection layer: the shared dashboard glass stays unchanged.
class ProfileGlassLighting extends StatelessWidget {
  final Widget child;

  const ProfileGlassLighting({super.key, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x2435AC7A), Color(0x050D3023), Color(0x60030907)],
        stops: [0, .34, 1],
      ),
    ),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-.7, -1.1),
          radius: 1.1,
          colors: [Color(0x148ADFB1), Color(0x008ADFB1)],
        ),
      ),
      child: child,
    ),
  );
}

/// A diffuse shadow illuminates the upper group without painting a new page
/// background, allocating a backdrop filter, or changing the child's geometry.
class ProfileUpperLighting extends StatelessWidget {
  final Widget child;

  const ProfileUpperLighting({super.key, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1622B477),
          blurRadius: 64,
          spreadRadius: 14,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: child,
  );
}

class _EmeraldGlassAvatar extends StatelessWidget {
  final double size;
  final Widget child;

  const _EmeraldGlassAvatar({required this.size, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      // Translucent emerald allows the existing card reflection to show through.
      gradient: const RadialGradient(
        center: Alignment(-.22, -.25),
        radius: .95,
        colors: [Color(0xB02D9569), Color(0xA00D5038), Color(0x80102C23)],
        stops: [0, .48, 1],
      ),
      border: Border.all(color: const Color(0x2476DBAF), width: .6),
      boxShadow: const [BoxShadow(color: Color(0x1026C580), blurRadius: 12)],
    ),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-.7, -.8),
          radius: .85,
          colors: [Color(0x24DDFFF0), Color(0x00DDFFF0)],
        ),
      ),
      child: SizedBox.expand(child: Center(child: child)),
    ),
  );
}

/// The parent owns the single glass surface; rows have transparent ink only.
class ProfileMenuRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool glow;
  final bool loading;

  const ProfileMenuRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.glow = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    label: loading ? 'Logging out' : label,
    button: true,
    enabled: onTap != null,
    onTap: onTap,
    excludeSemantics: true,
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: onTap,
        splashColor: DigiGymDarkColors.electricGreen.withValues(alpha: .10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                if (loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    icon,
                    size: 22,
                    color: color ?? DigiGymDarkColors.primaryText,
                    shadows: glow && color != null
                        ? [
                            Shadow(
                              color: color!.withValues(alpha: .58),
                              blurRadius: 7,
                            ),
                            Shadow(
                              color: color!.withValues(alpha: .24),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    loading ? 'Logging out…' : label,
                    style: TextStyle(
                      fontSize: 16,
                      color: color,
                      shadows: glow && color != null
                          ? [
                              Shadow(
                                color: color!.withValues(alpha: .45),
                                blurRadius: 6,
                              ),
                              Shadow(
                                color: color!.withValues(alpha: .18),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: DigiGymDarkColors.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class ProfileSummaryStat extends StatelessWidget {
  // Exact softer stop of the approved Login button's existing green gradient.
  static const iconColor = Color(0xFF67E780);

  final IconData? icon;
  final String? iconAsset;
  final double iconSize;
  final double? iconWidth;
  final bool pixelated;
  final Color? valueColor;
  final String value;
  final String label;
  final String? unit;

  const ProfileSummaryStat({
    super.key,
    this.icon,
    this.iconAsset,
    this.iconSize = 24,
    this.iconWidth,
    this.pixelated = false,
    this.valueColor,
    required this.value,
    required this.label,
    this.unit,
  }) : assert((icon == null) != (iconAsset == null));

  factory ProfileSummaryStat.level({
    Key? key,
    required String value,
  }) => ProfileSummaryStat(
    key: key,
    iconAsset: 'assets/images/digigym_workout_icon.png',
    iconSize: 28.5,
    // The official artwork is wide; retain the approved icon's aspect ratio.
    iconWidth: 38,
    pixelated: true,
    value: value,
    label: 'Level',
    valueColor: DigiGymFitnessLevelColors.forLevel(value),
  );

  factory ProfileSummaryStat.goal({Key? key, required String value}) =>
      ProfileSummaryStat(
        key: key,
        iconAsset: value == 'Build Muscle'
            ? 'assets/icons/biceps_flexed.png'
            : null,
        icon: value == 'Build Muscle'
            ? null
            : switch (value) {
                'Lose Weight' => Icons.monitor_weight_outlined,
                'Maintain Weight' => Icons.balance_outlined,
                'Gain Weight' => Icons.trending_up_rounded,
                _ => Icons.track_changes_outlined,
              },
        iconSize: value == 'Build Muscle' ? 25.5 : 27,
        value: value,
        label: 'Goal',
      );

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value${unit == null ? '' : ' $unit'}',
    excludeSemantics: true,
    child: ConstrainedBox(
      // Match the approved panel at normal scale; wrapped/accessible values grow.
      constraints: const BoxConstraints(minHeight: 120),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 36,
              child: Center(
                child: iconAsset != null
                    ? _assetIcon()
                    : Icon(
                        icon,
                        size: iconSize,
                        color: iconColor,
                        shadows: [
                          Shadow(
                            color: iconColor.withValues(alpha: .10),
                            blurRadius: 4,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            if (unit != null)
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.textScalerOf(context).scale(22),
                ),
                child: _durationValue(context),
              )
            else
              Text(
                '$value${unit == null ? '' : ' $unit'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: DigiGymDashboardTheme.textFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  // Preserve the approved 22px value line box and 120px panel.
                  height: 22 / 14,
                  color: valueColor ?? DigiGymDarkColors.primaryText,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                // Keep the previous 12sp label line box as the glyphs shrink.
                height:
                    (DefaultTextStyle.of(context).style.height ?? 1) * 12 / 11,
                color: DigiGymDarkColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _assetIcon() {
    final image = Image.asset(
      iconAsset!,
      width: iconWidth ?? iconSize,
      height: iconSize,
      fit: BoxFit.contain,
      filterQuality: pixelated ? FilterQuality.none : FilterQuality.low,
      color: iconColor,
      colorBlendMode: BlendMode.srcIn,
      excludeFromSemantics: true,
    );
    if (iconAsset != 'assets/icons/biceps_flexed.png') return image;
    // A fractional inset thins this rendered outline only. The shared artwork
    // and the official pixel dumbbell are never edited or filtered.
    return ImageFiltered(
      imageFilter: ui.ImageFilter.erode(radiusX: .12, radiusY: .12),
      child: image,
    );
  }

  Widget _durationValue(BuildContext context) {
    const style = TextStyle(
      fontFamily: DigiGymDashboardTheme.textFont,
      fontSize: 14,
      height: 1.1,
      color: DigiGymDarkColors.primaryText,
    );
    final inherited = DefaultTextStyle.of(context);
    final effectiveStyle = inherited.style.merge(style);
    final span = TextSpan(
      style: effectiveStyle,
      children: [
        TextSpan(
          text: value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        TextSpan(
          text: ' $unit',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
    TextPainter measure(InlineSpan text) => TextPainter(
      text: text,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior: inherited.textHeightBehavior,
    )..layout();
    final reference = measure(
      TextSpan(
        text: 'M',
        style: effectiveStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 22 / 14,
        ),
      ),
    );
    final duration = measure(span);
    final alignment = _ProfileDurationAlignment(
      naturalSize: duration.size,
      baseline: duration.computeDistanceToActualBaseline(
        TextBaseline.alphabetic,
      ),
      targetBaseline: reference.computeDistanceToActualBaseline(
        TextBaseline.alphabetic,
      ),
    );
    reference.dispose();
    duration.dispose();
    return CustomSingleChildLayout(
      delegate: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(span, style: style),
      ),
    );
  }
}

/// Match the unchanged value baselines using font metrics, including the
/// FittedBox transform for long durations or enlarged accessibility text.
class _ProfileDurationAlignment extends SingleChildLayoutDelegate {
  final Size naturalSize;
  final double baseline;
  final double targetBaseline;

  const _ProfileDurationAlignment({
    required this.naturalSize,
    required this.baseline,
    required this.targetBaseline,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    final scale = math.min(1.0, constraints.maxWidth / naturalSize.width);
    return constraints.constrain(naturalSize * scale);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.tight(getSize(constraints));

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final scale = math.min(
      1.0,
      math.min(
        childSize.width / naturalSize.width,
        childSize.height / naturalSize.height,
      ),
    );
    final paintedBaseline =
        (childSize.height - naturalSize.height * scale) / 2 + baseline * scale;
    return Offset(0, targetBaseline - paintedBaseline);
  }

  @override
  bool shouldRelayout(_ProfileDurationAlignment oldDelegate) =>
      naturalSize != oldDelegate.naturalSize ||
      baseline != oldDelegate.baseline ||
      targetBaseline != oldDelegate.targetBaseline;
}
