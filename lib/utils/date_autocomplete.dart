class DateAutoComplete {
  static Map<String, DateRange> calculateDateRange(String period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;
    switch (period) {
      case '1 month':
        startDate = DateTime(now.year, now.month - 1, now.day, 0, 0, 0);
        endDate = now;
        break;
      case '3 months':
        startDate = DateTime(now.year, now.month - 3, now.day, 0, 0, 0);
        endDate = now;
        break;
      case '6 months':
        startDate = DateTime(now.year, now.month - 6, now.day, 0, 0, 0);
        endDate = now;
        break;
      case '1 year':
        startDate = DateTime(now.year - 1, now.month, now.day, 0, 0, 0);
        endDate = now;
        break;
      case 'All time':
        // ตั้งแต่ปี 2020 หรือตามที่ระบบเริ่มมีข้อมูล
        startDate = DateTime(2010, 1, 1, 0, 0, 0);
        endDate = now;
        break;
      default: // 'กำหนดเอง'
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        endDate = now;
        break;
    }

    return {
      'startDate': DateRange(startDate, true), // true = start date
      'endDate': DateRange(endDate, false),    // false = end date
    };
  }

  static String formatDateLabel(DateTime date, bool isStartDate) {
    if (isStartDate) {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      return _formatToLabel(startOfDay);
    } else {
      return _formatToLabel(date);
    }
  }

  static String _formatToLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${(date.year % 100).toString().padLeft(2, '0')}';
  }

  static DateTime parseFromLabel(String label) {
    final parts = label.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = 2000 + int.parse(parts[2]);
      return DateTime(year, month, day);
    }
    return DateTime.now();
  }
}

class DateRange {
  final DateTime date;
  final bool isStartDate;
  
  DateRange(this.date, this.isStartDate);
}