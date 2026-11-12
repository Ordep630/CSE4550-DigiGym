import 'dart:ui' as ui;

import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every digit has a distinct seven-row glyph with a rectangular zero',
    () {
      final digits = [
        for (var i = 0; i <= 9; i++) DotMatrixPainter.glyphs['$i']!,
      ];
      expect(digits.map((g) => g.join()).toSet(), hasLength(10));
      for (final glyph in digits) {
        expect(glyph, hasLength(7));
        expect(glyph.map((r) => r.length), everyElement(5));
      }
      expect(digits.first.first, '01110');
      expect(digits.first.last, '01110');
      expect(digits.first.sublist(1, 6), everyElement('10001'));
      expect(() => DotMatrixText(text: 'ABC'), throwsArgumentError);
    },
  );

  test('digits have one pitch and percent is exactly one-third height', () {
    const height = 44.0;
    final pitch = height / (6 + DotMatrixPainter.dotRatio);
    final radius = pitch * DotMatrixPainter.dotRatio / 2;
    for (final value in ['0%', '25%', '75%', '100%']) {
      final dots = DotMatrixPainter.dotsFor(
        value,
        height,
        softenedDigits: true,
      );
      final width = DotMatrixPainter.widthFor(value, height);
      final digits = dots.where((dot) => dot.radius > radius / 2);
      final percent = dots.where((dot) => dot.radius < radius / 2).toList();
      expect(digits.map((d) => d.radius), everyElement(closeTo(radius, .0001)));
      expect(
        percent.map((d) => d.radius),
        everyElement(closeTo(radius / 3, .0001)),
      );
      for (final dot in dots) {
        expect(dot.center.dx - dot.radius, greaterThanOrEqualTo(-.0001));
        expect(dot.center.dx + dot.radius, lessThanOrEqualTo(width + .0001));
        expect(dot.center.dy - dot.radius, greaterThanOrEqualTo(-.0001));
        expect(dot.center.dy + dot.radius, lessThanOrEqualTo(height + .0001));
      }
      for (final dot in digits) {
        final column = (dot.center.dx - radius) / pitch;
        final row = (dot.center.dy - radius) / pitch;
        expect(column, closeTo(column.round(), .0001));
        expect(row, closeTo(row.round(), .0001));
      }
      final top = percent
          .map((d) => d.center.dy - d.radius)
          .reduce((a, b) => a < b ? a : b);
      final bottom = percent
          .map((d) => d.center.dy + d.radius)
          .reduce((a, b) => a > b ? a : b);
      expect(bottom - top, closeTo(height / 3, .0001));
      expect(bottom, closeTo(height, .0001));
    }
  });

  test('workout uses shared 3 and 0 patterns with fuller dots that remain separated and bounded', () {
    for (final value in ['0', '3', '30', '125']) {
      const height = 43.2;
      const fill = .74;
      final dots = DotMatrixPainter.dotsFor(
        value,
        height,
        softenedDigits: true,
        fillRatio: fill,
      );
      final width = DotMatrixPainter.widthFor(value, height, fillRatio: fill);
      final pitch = height / (6 + fill);
      expect(
        dots,
        hasLength(
          value
              .split('')
              .fold<int>(
                0,
                (sum, digit) =>
                    sum +
                    DotMatrixPainter.glyphs[digit]!
                        .join()
                        .split('')
                        .where((bit) => bit == '1')
                        .length,
              ),
        ),
      );
      expect(
        dots.first.radius,
        greaterThan(
          DotMatrixPainter.dotsFor(
            value,
            height,
            softenedDigits: true,
          ).first.radius,
        ),
      );
      expect(dots.first.radius * 2, lessThan(pitch));
      for (final dot in dots) {
        expect(dot.center.dx - dot.radius, greaterThanOrEqualTo(-.001));
        expect(dot.center.dx + dot.radius, lessThanOrEqualTo(width + .001));
        expect(dot.center.dy - dot.radius, greaterThanOrEqualTo(-.001));
        expect(dot.center.dy + dot.radius, lessThanOrEqualTo(height + .001));
      }
    }
    expect(() => DotMatrixText(text: '30', fillRatio: 1), throwsArgumentError);
  });

  test('calendar date keeps its approved digit shapes and geometry', () {
    const oldTwo = [
      '11111',
      '00001',
      '00001',
      '11111',
      '10000',
      '10000',
      '11111',
    ];
    const oldFive = [
      '11111',
      '10000',
      '10000',
      '11111',
      '00001',
      '00001',
      '11111',
    ];
    const height = 48.0;
    const pitch = height / (6 + DotMatrixPainter.dotRatio);
    const radius = pitch * DotMatrixPainter.dotRatio / 2;
    final expected = <Offset>[];
    for (var glyph = 0; glyph < 2; glyph++) {
      final rows = [oldTwo, oldFive][glyph];
      for (var y = 0; y < 7; y++) {
        for (var x = 0; x < 5; x++) {
          if (rows[y][x] == '1') {
            expected.add(
              Offset(radius + (glyph * 6 + x) * pitch, radius + y * pitch),
            );
          }
        }
      }
    }
    final actual = DotMatrixPainter.dotCenters('25', height);
    expect(actual.length, expected.length);
    for (var i = 0; i < expected.length; i++) {
      expect((actual[i] - expected[i]).distance, lessThan(.000001));
    }
  });

  test(
    'painter produces visible separated dots for 0, 25 and 100 percent',
    () async {
      for (final value in ['0%', '25%', '75%', '100%']) {
        const height = 70.0;
        final width = DotMatrixPainter.widthFor(value, height).ceil();
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        const color = Color(0xFFF4F7F5);
        const radius =
            height /
            (6 + DotMatrixPainter.dotRatio) *
            DotMatrixPainter.dotRatio /
            2;
        DotMatrixPainter(
          text: value,
          color: color,
          softenedDigits: true,
        ).paint(canvas, Size(width.toDouble(), height));
        final picture = recorder.endRecording();
        final image = await picture.toImage(width, height.toInt());
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        for (final dot in DotMatrixPainter.dotsFor(
          value,
          height,
          softenedDigits: true,
        )) {
          final point = dot.center;
          final offset = (point.dy.floor() * width + point.dx.floor()) * 4;
          expect(bytes!.getUint8(offset + 3), greaterThan(0));
        }
        final gap =
            DotMatrixPainter.dotCenters(value, height).first +
            const Offset(radius + 2, 0);
        expect(
          bytes!.getUint8((gap.dy.floor() * width + gap.dx.floor()) * 4 + 3),
          0,
        );
        image.dispose();
        picture.dispose();
      }
    },
  );

  testWidgets('custom matrix supplies accessible meaning without overflow', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final value in ['0%', '25%', '75%', '100%']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 70,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DotMatrixText(
                    text: value,
                    semanticLabel: '$value complete',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('$value complete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    semantics.dispose();
  });
}
