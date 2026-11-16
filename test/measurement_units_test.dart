import 'package:digigym/utils/measurement_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'food portions use ounces without changing nutrition or item counts',
    () {
      expect(MeasurementUnits.ouncesToGrams(1), 28.349523125);
      expect(MeasurementUnits.gramsToOunces(28.349523125), 1);
      expect(
        MeasurementUnits.formatFoodPortion('150g chicken + 200g rice'),
        '5.3 oz chicken + 7.1 oz rice',
      );
      expect(
        MeasurementUnits.formatFoodPortion('2 eggs + 2 slices toast'),
        '2 eggs + 2 slices toast',
      );
      expect(MeasurementUnits.gramsToOunces(0), 0);
      expect(MeasurementUnits.ouncesToGrams(0), 0);
      expect(
        () => MeasurementUnits.gramsToOunces(double.nan),
        throwsArgumentError,
      );
      expect(() => MeasurementUnits.ouncesToGrams(-1), throwsArgumentError);
    },
  );
  test('exact standard constants and common weight conversions', () {
    expect(MeasurementUnits.poundsToKilograms(1), .45359237);
    expect(MeasurementUnits.kilogramsToPounds(.45359237), 1);
    expect(
      MeasurementUnits.kilogramsToPounds(58),
      closeTo(127.868112067, 1e-8),
    );
    expect(MeasurementUnits.poundsToKilograms(200), 90.718474);
    expect(MeasurementUnits.formatWeight(58), '127.9 lb');
  });
  test(
    'height conversions preserve fractional inches and carry rounded feet',
    () {
      expect(MeasurementUnits.feetInchesToCentimeters(5, 11), 180.34);
      final height = MeasurementUnits.centimetersToFeetInches(180.34);
      expect(height.feet, 5);
      expect(height.inches, closeTo(11, 1e-12));
      expect(MeasurementUnits.formatHeight(174), '5 ft 8.5 in');
      expect(MeasurementUnits.formatHeight(182.879), '6 ft 0 in');
      expect(MeasurementUnits.centimetersToFeetInches(0), (
        feet: 0,
        inches: 0.0,
      ));
    },
  );
  test('US fluid ounces use US customary volume, not UK imperial volume', () {
    expect(MeasurementUnits.usFluidOuncesToLiters(128), 3.785411784);
    expect(
      MeasurementUnits.litersToUsFluidOunces(1),
      closeTo(33.8140227018, 1e-9),
    );
    expect(MeasurementUnits.usFluidOuncesToLiters(1), .0295735295625);
  });
  test(
    'unrounded round trips stay accurate, including zero and boundary cases',
    () {
      for (final value in [0.0, .01, 1.0, 2.54, 58.0, 180.34, 250.0, 1000.0]) {
        expect(
          MeasurementUnits.poundsToKilograms(
            MeasurementUnits.kilogramsToPounds(value),
          ),
          closeTo(value, 1e-10),
        );
        expect(
          MeasurementUnits.usFluidOuncesToLiters(
            MeasurementUnits.litersToUsFluidOunces(value),
          ),
          closeTo(value, 1e-10),
        );
        final h = MeasurementUnits.centimetersToFeetInches(value);
        expect(
          MeasurementUnits.feetInchesToCentimeters(h.feet, h.inches),
          closeTo(value, 1e-10),
        );
      }
    },
  );
  test(
    'negative and nonfinite measurements are rejected by all converters',
    () {
      for (final invalid in [
        -1.0,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        for (final convert in [
          MeasurementUnits.kilogramsToPounds,
          MeasurementUnits.poundsToKilograms,
          MeasurementUnits.litersToUsFluidOunces,
          MeasurementUnits.usFluidOuncesToLiters,
        ]) {
          expect(() => convert(invalid), throwsArgumentError);
        }
        expect(
          () => MeasurementUnits.centimetersToFeetInches(invalid),
          throwsArgumentError,
        );
        expect(
          () => MeasurementUnits.feetInchesToCentimeters(5, invalid),
          throwsArgumentError,
        );
      }
      expect(
        () => MeasurementUnits.feetInchesToCentimeters(-1, 0),
        throwsArgumentError,
      );
      expect(
        () => MeasurementUnits.feetInchesToCentimeters(5, 12),
        throwsArgumentError,
      );
      expect(
        () => MeasurementUnits.centimetersToFeetInches(170, fractionDigits: -1),
        throwsArgumentError,
      );
    },
  );
  test('form parsing blocks empty, nonnumeric, zero, and invalid inputs', () {
    for (final value in ['', 'bad', '0', '-1', 'NaN', 'Infinity']) {
      expect(MeasurementUnits.parseWeight(value), isNull);
    }
    for (final pair in [
      ('', '1'),
      ('5', ''),
      ('0', '0'),
      ('-1', '0'),
      ('5', '12'),
      ('5', '-1'),
      ('5', 'NaN'),
      ('5.5', '0'),
    ]) {
      expect(MeasurementUnits.parseHeight(pair.$1, pair.$2), isNull);
    }
    expect(MeasurementUnits.parseHeight('5', '11.5'), 181.61);
    expect(MeasurementUnits.parseWeight('200'), 90.718474);
  });
}
