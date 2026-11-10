/// The existing Workout duration's 5x7 round-dot treatment, shared by prominent
/// numeric displays. Doto remains the bundled reference/fallback typeface.
abstract final class DigiGymDotTypography {
  static const fillRatio = .74;
  static const softenedDigits = true;
  static const fontToDotHeight = .9;
  static const workoutHeight = 48 * fontToDotHeight;
  static const calendarHeight = 48.0;
  static const progressHeight = 44.0;
  static const unitGap = 6.0;

  // Only the three right-hand dashboard statistics use the fuller Stage 1D
  // dots. Reduce their paint by 5% inside the retained row/line metrics, so
  // unit labels and width fitting keep their exact Stage 1D positions.
  static const statisticFillRatio = .88;
  static const statisticHeightScale = .92;
  static const statisticPaintScale = .95;

  static double heightForFontSize(double fontSize) =>
      fontSize * fontToDotHeight;
}
