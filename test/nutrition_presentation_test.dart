import 'package:digigym/utils/bmi_category.dart';
import 'package:digigym/utils/calorie_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Cal formatting preserves numerical values and optional digit grouping',
    () {
      expect(CalorieFormat.unit, 'Cal');
      for (final value in [0, 250, 590, 1818, 1234567, -100]) {
        expect(CalorieFormat.format(value), '$value Cal');
      }
      expect(CalorieFormat.format(1818, grouped: true), '1,818 Cal');
      expect(CalorieFormat.format(1234567, grouped: true), '1,234,567 Cal');
      expect(CalorieFormat.format(590, grouped: true), '590 Cal');
      expect(CalorieFormat.format(-1000, grouped: true), '-1,000 Cal');
    },
  );

  for (final entry in <double, BmiCategory>{
    18.49: BmiCategory.underweight,
    18.49999: BmiCategory.underweight,
    18.5: BmiCategory.healthyWeight,
    19.2: BmiCategory.healthyWeight,
    24.9: BmiCategory.healthyWeight,
    24.99999: BmiCategory.healthyWeight,
    25: BmiCategory.overweight,
    29.99999: BmiCategory.overweight,
    30: BmiCategory.obesity,
    40: BmiCategory.obesity,
  }.entries) {
    test('BMI ${entry.key} uses the unrounded ${entry.value.name} band', () {
      expect(BmiCategory.fromValue(entry.key), entry.value);
    });
  }

  test('missing nonfinite and nonpositive BMI values have no category', () {
    for (final value in [
      null,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      0.0,
      -1.0,
    ]) {
      expect(BmiCategory.fromValue(value), isNull);
    }
  });
}
