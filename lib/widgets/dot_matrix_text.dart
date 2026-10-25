import 'package:flutter/material.dart';

/// Fixed 5x7 digits with a shared pitch and a compact, one-third-height %.
/// Used only for the progress percentage and the large local calendar date.
class DotMatrixText extends StatelessWidget {
  final String text;
  final double height;
  final Color? color;
  final String? semanticLabel;
  final bool softenedDigits;
  final bool scaleWithText;

  DotMatrixText({
    super.key,
    required this.text,
    this.height = 44,
    this.color,
    this.semanticLabel,
    this.softenedDigits = false,
    this.scaleWithText = true,
  }) {
    if (!height.isFinite || height <= 0) {
      throw ArgumentError.value(
        height,
        'height',
        'Use a positive finite height',
      );
    }
    if (text.isEmpty ||
        text.split('').any((c) => !DotMatrixPainter.glyphs.containsKey(c))) {
      throw ArgumentError.value(
        text,
        'text',
        'Use digits, a decimal point or %',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaledHeight = scaleWithText
        ? MediaQuery.textScalerOf(context).scale(height)
        : height;
    return Semantics(
      label: semanticLabel ?? text,
      excludeSemantics: true,
      child: SizedBox(
        width: DotMatrixPainter.widthFor(text, scaledHeight),
        height: scaledHeight,
        child: CustomPaint(
          painter: DotMatrixPainter(
            text: text,
            color: color ?? Theme.of(context).colorScheme.onSurface,
            softenedDigits: softenedDigits,
          ),
        ),
      ),
    );
  }
}

class DotMatrixPainter extends CustomPainter {
  final String text;
  final Color color;
  final bool softenedDigits;
  static const dotRatio = .68;
  static const percentScale = 1 / 3;
  static const glyphs = <String, List<String>>{
    '0': ['01110', '10001', '10001', '10001', '10001', '10001', '01110'],
    '1': ['00100', '01100', '00100', '00100', '00100', '00100', '01110'],
    '2': ['01110', '10001', '00001', '00010', '00100', '01000', '11111'],
    '3': ['11110', '00001', '00001', '01110', '00001', '00001', '11110'],
    '4': ['10001', '10001', '10001', '11111', '00001', '00001', '00001'],
    '5': ['11111', '10000', '10000', '11110', '00001', '00001', '11110'],
    '6': ['01110', '10000', '10000', '11110', '10001', '10001', '01110'],
    '7': ['11111', '00001', '00010', '00100', '01000', '01000', '01000'],
    '8': ['01110', '10001', '10001', '01110', '10001', '10001', '01110'],
    '9': ['01110', '10001', '10001', '01111', '00001', '00001', '01110'],
    '%': ['11001', '11010', '00010', '00100', '01000', '01011', '10011'],
    '.': ['0', '0', '0', '0', '0', '0', '1'],
  };

  const DotMatrixPainter({
    required this.text,
    required this.color,
    this.softenedDigits = false,
  });

  // Preserve the already-approved large calendar date when refining only the
  // progress typography. Both variants retain the same 5x7 geometry and pitch.
  static const _dateGlyphs = <String, List<String>>{
    '0': ['11111', '10001', '10001', '10001', '10001', '10001', '11111'],
    '2': ['11111', '00001', '00001', '11111', '10000', '10000', '11111'],
    '3': ['11111', '00001', '00001', '01111', '00001', '00001', '11111'],
    '5': ['11111', '10000', '10000', '11111', '00001', '00001', '11111'],
    '6': ['11111', '10000', '10000', '11111', '10001', '10001', '11111'],
    '8': ['11111', '10001', '10001', '11111', '10001', '10001', '11111'],
    '9': ['11111', '10001', '10001', '11111', '00001', '00001', '11111'],
  };

  static double widthFor(String text, double height) {
    final pitch = height / (6 + dotRatio);
    return text
            .split('')
            .fold(
              0.0,
              (width, char) =>
                  width +
                  (glyphs[char]!.first.length - 1 + dotRatio) *
                      pitch *
                      (char == '%' ? percentScale : 1) +
                  pitch * (2 - dotRatio),
            ) -
        pitch * (2 - dotRatio);
  }

  /// Digits use one lattice. The compact % uses the same round dot style at 1/3
  /// scale and aligns with the digit baseline, rather than changing digit size.
  static List<DotMatrixDot> dotsFor(
    String text,
    double height, {
    bool softenedDigits = false,
  }) {
    final pitch = height / (6 + dotRatio);
    final dots = <DotMatrixDot>[];
    var left = 0.0;
    for (final char in text.split('')) {
      final rows =
          (!softenedDigits ? _dateGlyphs[char] : null) ?? glyphs[char]!;
      final scale = char == '%' ? percentScale : 1.0;
      final glyphPitch = pitch * scale;
      final radius = glyphPitch * dotRatio / 2;
      final top = height * (1 - scale);
      for (var y = 0; y < rows.length; y++) {
        for (var x = 0; x < rows[y].length; x++) {
          if (rows[y][x] == '1') {
            dots.add(
              DotMatrixDot(
                Offset(
                  left + radius + x * glyphPitch,
                  top + radius + y * glyphPitch,
                ),
                radius,
              ),
            );
          }
        }
      }
      left +=
          (rows.first.length - 1 + dotRatio) * glyphPitch +
          pitch * (2 - dotRatio);
    }
    return dots;
  }

  static List<Offset> dotCenters(String text, double height) =>
      dotsFor(text, height).map((dot) => dot.center).toList();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final dot in dotsFor(
      text,
      size.height,
      softenedDigits: softenedDigits,
    )) {
      canvas.drawCircle(dot.center, dot.radius, paint);
    }
  }

  @override
  bool shouldRepaint(DotMatrixPainter oldDelegate) =>
      text != oldDelegate.text ||
      color != oldDelegate.color ||
      softenedDigits != oldDelegate.softenedDigits;
}

class DotMatrixDot {
  final Offset center;
  final double radius;
  const DotMatrixDot(this.center, this.radius);
}
