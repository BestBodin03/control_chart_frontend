class CountExtractor {
  static int extractCountFromResponse(dynamic response) {
    try {
      if (response is List && response.isNotEmpty) {
        final firstItem = response[0] as Map<String, dynamic>;
        return firstItem['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error extracting count: $e');
      return 0;
    }
  }
}