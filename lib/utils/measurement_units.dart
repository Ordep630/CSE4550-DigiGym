/// Presentation conversions only. UserProfile and Serverpod remain in cm/kg.
abstract final class MeasurementUnits {
  static const kilogramsPerPound = 0.45359237;
  static const centimetersPerInch = 2.54;
  static const litersPerUsFluidOunce = 0.0295735295625;
  static const gramsPerOunce = 28.349523125;

  static double _measurement(double value) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Use a finite, nonnegative measurement',
      );
    }
    return value;
  }

  static double kilogramsToPounds(double kilograms) =>
      _measurement(kilograms) / kilogramsPerPound;
  static double poundsToKilograms(double pounds) =>
      _measurement(pounds) * kilogramsPerPound;
  static double litersToUsFluidOunces(double liters) =>
      _measurement(liters) / litersPerUsFluidOunce;
  static double usFluidOuncesToLiters(double ounces) =>
      _measurement(ounces) * litersPerUsFluidOunce;
  static double gramsToOunces(double grams) =>
      _measurement(grams) / gramsPerOunce;
  static double ouncesToGrams(double ounces) =>
      _measurement(ounces) * gramsPerOunce;

  /// Food portions use ounces; nutritional protein reporting stays in grams.
  static String formatFoodPortion(String portion) => portion.replaceAllMapped(
    RegExp(r'(\d+(?:\.\d+)?)\s*g\b'),
    (match) =>
        '${gramsToOunces(double.parse(match[1]!)).toStringAsFixed(1)} oz',
  );

  /// Omit [fractionDigits] for an unrounded, reversible conversion.
  static ({int feet, double inches}) centimetersToFeetInches(
    double centimeters, {
    int? fractionDigits,
  }) {
    if (fractionDigits != null && (fractionDigits < 0 || fractionDigits > 6)) {
      throw ArgumentError.value(fractionDigits, 'fractionDigits');
    }
    final totalInches = _measurement(centimeters) / centimetersPerInch;
    var feet = totalInches ~/ 12;
    var inches = totalInches - feet * 12;
    if (fractionDigits != null) {
      inches = double.parse(inches.toStringAsFixed(fractionDigits));
      if (inches >= 12) {
        feet++;
        inches = 0;
      }
    }
    return (feet: feet, inches: inches);
  }

  static double feetInchesToCentimeters(int feet, double inches) {
    if (feet < 0 || !inches.isFinite || inches < 0 || inches >= 12) {
      throw ArgumentError('Use nonnegative feet and inches from 0 up to 12');
    }
    return (feet * 12 + inches) * centimetersPerInch;
  }

  static String formatWeight(double kilograms) =>
      '${kilogramsToPounds(kilograms).toStringAsFixed(1)} lb';

  static String formatHeight(double centimeters) {
    final height = centimetersToFeetInches(centimeters, fractionDigits: 1);
    final inches = height.inches
        .toStringAsFixed(1)
        .replaceFirst(RegExp(r'\.0$'), '');
    return '${height.feet} ft $inches in';
  }

  /// Invalid or incomplete form input never reaches profile persistence.
  static double? parseHeight(String feetText, String inchesText) {
    final feet = int.tryParse(feetText.trim());
    final inches = double.tryParse(inchesText.trim());
    if (feet == null ||
        inches == null ||
        feet < 0 ||
        !inches.isFinite ||
        inches < 0 ||
        inches >= 12) {
      return null;
    }
    final centimeters = feetInchesToCentimeters(feet, inches);
    return centimeters.isFinite && centimeters > 0 ? centimeters : null;
  }

  static double? parseWeight(String poundsText) {
    final pounds = double.tryParse(poundsText.trim());
    if (pounds == null || !pounds.isFinite || pounds <= 0) return null;
    final kilograms = poundsToKilograms(pounds);
    return kilograms.isFinite ? kilograms : null;
  }
}
