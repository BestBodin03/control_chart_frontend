enum PeriodDuration {
  sevenDays(days: 7),
  fourteenDays(days: 14),
  thirtyDays(days: 30),
  sixtyDays(days: 60);

  final int days;
  const PeriodDuration({required this.days});

  int get milliseconds => days * 24 * 60 * 60 * 1000;

  String get label {
    switch (this) {
      case PeriodDuration.sevenDays:
        return '7 Days';
      case PeriodDuration.fourteenDays:
        return '14 Days';
      case PeriodDuration.thirtyDays:
        return '30 Days';
      case PeriodDuration.sixtyDays:
        return '60 Days';
    }
  }

  static PeriodDuration fromLabel(String label) {
    switch (label.toLowerCase()) {
      case '7 days':
      case '1 week':
        return PeriodDuration.sevenDays;
      case '14 days':
      case '2 weeks':
        return PeriodDuration.fourteenDays;
      case '30 days':
      case '1 month':
        return PeriodDuration.thirtyDays;
      case '60 days':
      case '2 months':
        return PeriodDuration.sixtyDays;
      default:
        return PeriodDuration.thirtyDays;
    }
  }
}
