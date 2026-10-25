import 'package:flutter/material.dart';

import 'digigym_form_components.dart';

/// Shares the existing height row; wraps instead of shrinking accessible text.
class ImperialHeightInput extends StatelessWidget {
  final TextEditingController feetController;
  final TextEditingController inchesController;

  const ImperialHeightInput({
    super.key,
    required this.feetController,
    required this.inchesController,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      Widget field(
        String unit,
        TextEditingController controller, {
        bool decimal = false,
      }) => DigiGymGlassField(
        child: TextField(
          key: ValueKey('height-$unit'),
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          textInputAction: TextInputAction.next,
          decoration: digiGymFormDecoration('Height ($unit)'),
        ),
      );
      final feet = field('ft', feetController);
      final inches = field('in', inchesController, decimal: true);
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(16) > 20.8) {
        return Column(children: [feet, const SizedBox(height: 15), inches]);
      }
      return Row(
        children: [
          Expanded(child: feet),
          const SizedBox(width: 12),
          Expanded(child: inches),
        ],
      );
    },
  );
}
