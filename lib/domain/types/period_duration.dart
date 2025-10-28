/// Canonical, strict period choices: 1D, 1W, 1M, 2M
enum PeriodDuration {
  oneDay(days: 1, label: '1D'),
  oneWeek(days: 7, label: '1W'),
  oneMonth(days: 30, label: '1M'),
  twoMonths(days: 60, label: '2M');

  final int days;
  final String label;
  const PeriodDuration({required this.days, required this.label});

  double get milliseconds => days * 24 * 60 * 60 * 1000;

  /// Strict parser: accepts ONLY 1D / 1W / 1M / 2M (case-insensitive).
  static PeriodDuration fromLabel(String s) {
    switch (s.trim().toUpperCase()) {
      case '1D': return PeriodDuration.oneDay;
      case '1W': return PeriodDuration.oneWeek;
      case '1M': return PeriodDuration.oneMonth;
      case '2M': return PeriodDuration.twoMonths;
      default:   return PeriodDuration.oneMonth; // or throw if you prefer strict failure
    }
  }

  /// Strict from days: accepts ONLY 1, 7, 30, 60.
  static PeriodDuration fromDays(int d) {
    switch (d) {
      case 1:  return PeriodDuration.oneDay;
      case 7:  return PeriodDuration.oneWeek;
      case 30: return PeriodDuration.oneMonth;
      case 60: return PeriodDuration.twoMonths;
      default: return PeriodDuration.oneMonth; // or throw
    }
  }

  @override
  String toString() => label; // canonical string
}
