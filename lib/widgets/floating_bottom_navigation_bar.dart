import 'dart:ui';

import 'package:flutter/material.dart';

/// Presentation only: the parent owns the selected tab and its pages.
class FloatingBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const FloatingBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : assert(selectedIndex >= 0 && selectedIndex < 5);

  static const _labels = ['Home', 'Workout', 'Meals', 'Groceries', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.fitness_center,
    Icons.restaurant_outlined,
    Icons.shopping_basket_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selected = dark ? const Color(0xFF70FF45) : const Color(0xFF21865C);
    final inactive = dark ? const Color(0xFFA6AEAA) : const Color(0xFF626C66);
    final surface = dark
        ? const Color(0xFF1A201E).withValues(alpha: 0.20)
        : const Color(0xE6F5F8F5);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.22 : 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                  // A filled shadow behind translucent glass adds a second
                  // dark surface. Keep the dark-mode shadow outside its shape.
                  blurStyle: dark ? BlurStyle.outer : BlurStyle.normal,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Material(
                  color: surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                    side: BorderSide(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0x99FFFFFF),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Row(
                      children: List.generate(_labels.length, (index) {
                        final active = selectedIndex == index;
                        final color = active ? selected : inactive;
                        return Expanded(
                          child: Semantics(
                            selected: active,
                            button: true,
                            label: _labels[index],
                            onTap: () => onDestinationSelected(index),
                            excludeSemantics: true,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(36),
                              onTap: () => onDestinationSelected(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _SelectedIconGlow(
                                      key: ValueKey('navigation-icon-$index'),
                                      selected: active,
                                      dark: dark,
                                      child: index == 1
                                          ? Image.asset(
                                              'assets/images/digigym_workout_icon.png',
                                              width: 38,
                                              fit: BoxFit.contain,
                                              filterQuality: FilterQuality.none,
                                              color: color,
                                              colorBlendMode: BlendMode.srcIn,
                                            )
                                          : Icon(
                                              active && index == 0
                                                  ? Icons.home
                                                  : active && index == 4
                                                  ? Icons.person
                                                  : _icons[index],
                                              size: 24,
                                              color: color,
                                            ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        _labels[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          height: 1.2,
                                          color: color,
                                          fontWeight: active
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints illumination separately from the sharp icon in its original slot.
class _SelectedIconGlow extends StatelessWidget {
  final bool selected;
  final bool dark;
  final Widget child;

  const _SelectedIconGlow({
    super.key,
    required this.selected,
    required this.dark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (selected)
            Positioned.fill(
              child: IgnorePointer(
                key: const ValueKey('navigation-icon-glow'),
                child: ExcludeSemantics(
                  child: ClipRect(
                    // Fade at the slot edges so illumination cannot reach
                    // labels or neighboring destinations.
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0, 0.22, 0.78, 1],
                      ).createShader(bounds),
                      child: Opacity(
                        opacity: dark ? 0.85 : 0.32,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: dark ? 4 : 3,
                            sigmaY: dark ? 4 : 3,
                          ),
                          child: Center(child: child),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          KeyedSubtree(
            key: const ValueKey('navigation-icon-foreground'),
            child: child,
          ),
        ],
      ),
    );
  }
}
