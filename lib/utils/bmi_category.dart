/// Adult BMI screening bands, applied to the original, unrounded BMI.
enum BmiCategory {
  underweight('Below 18.5', 'Underweight'),
  healthyWeight('18.5–24.9', 'Healthy weight'),
  overweight('25.0–29.9', 'Overweight'),
  obesity('30.0 or higher', 'Obesity');

  final String range;
  final String label;
  const BmiCategory(this.range, this.label);

  static BmiCategory? fromValue(double? bmi) {
    if (bmi == null || !bmi.isFinite || bmi <= 0) return null;
    if (bmi < 18.5) return underweight;
    if (bmi < 25) return healthyWeight;
    if (bmi < 30) return overweight;
    return obesity;
  }
}
