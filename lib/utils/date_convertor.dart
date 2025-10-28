DateTime oneMonthAgo(DateTime date) {
  final prevMonth = date.month - 1;
  final year = prevMonth < 1 ? date.year - 1 : date.year;
  final month = prevMonth < 1 ? 12 : prevMonth;

  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDay ? lastDay : date.day;

  return DateTime(year, month, day, date.hour, date.minute, date.second);
}