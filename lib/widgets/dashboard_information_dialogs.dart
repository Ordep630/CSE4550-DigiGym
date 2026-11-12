import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import '../utils/bmi_category.dart';
import '../utils/measurement_units.dart';
import 'digigym_dialog.dart';

Future<void> showDashboardWeightDialog(
  BuildContext context, {
  required double weight,
  VoidCallback? onEditWeight,
}) async {
  final edit = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => DigiGymDialog(
      title: 'Your Weight',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MeasurementUnits.formatWeight(weight),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your current weight is based on the information in your fitness profile.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: onEditWeight == null
              ? null
              : () => Navigator.pop(dialogContext, true),
          child: const Text('Edit Weight'),
        ),
      ],
    ),
  );
  if (edit == true && context.mounted) onEditWeight?.call();
}

Future<void> showDashboardBmiDialog(
  BuildContext context, {
  required double? bmi,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => _BmiInformation(bmi: bmi),
);

class _BmiInformation extends StatelessWidget {
  final double? bmi;
  const _BmiInformation({required this.bmi});

  @override
  Widget build(BuildContext context) {
    final category = BmiCategory.fromValue(bmi);
    return DigiGymDialog(
      title: 'What is BMI?',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body Mass Index (BMI) is a simple measurement that compares your weight to your height.',
          ),
          const SizedBox(height: 16),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8, right: 12),
                    child: Text(
                      'BMI Range',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              for (final band in BmiCategory.values)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, right: 12),
                      child: Text(
                        band.range,
                        style: TextStyle(
                          color: band == category
                              ? DigiGymDarkColors.softGreen
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        band.label,
                        style: TextStyle(
                          color: band == category
                              ? DigiGymDarkColors.softGreen
                              : null,
                          fontWeight: band == category ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: category == null
                  ? const [
                      TextSpan(
                        text: 'Your BMI is unavailable. Review your height and weight in Edit Profile.',
                      ),
                    ]
                  : [
                      TextSpan(text: 'Your BMI: ${bmi!.toStringAsFixed(1)} — '),
                      TextSpan(
                        text: category.label,
                        style: const TextStyle(
                          color: DigiGymDarkColors.softGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'BMI is a general screening tool and doesn’t directly measure body fat or overall health.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got It'),
        ),
      ],
    );
  }
}
