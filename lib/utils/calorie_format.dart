/// Shared presentation for nutritional energy. One food Cal equals one kcal;
/// formatting never converts, rounds or changes the existing integer value.
/// Use this at the display boundary for targets, meals and nutrition widgets.
abstract final class CalorieFormat {
  static const unit = 'Cal';

  static String format(int value, {bool grouped = false}) {
    final number = grouped
        ? value.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]},',
          )
        : value.toString();
    return '$number $unit';
  }
}
