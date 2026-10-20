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
    final surface = dark ? const Color(0xE61A201E) : const Color(0xE6F5F8F5);

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
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Material(
                  color: surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                    side: BorderSide(
                      color: dark
                          ? const Color(0x33FFFFFF)
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
                                    Container(
                                      width: 44,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: active
                                            ? (dark
                                                  ? selected.withValues(
                                                      alpha: 0.16,
                                                    )
                                                  : const Color(0xFFCEF5DF))
                                            : Colors.transparent,
                                      ),
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
