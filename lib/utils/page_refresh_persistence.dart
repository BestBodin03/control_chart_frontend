import 'package:shared_preferences/shared_preferences.dart';

// Add this to your AppRoute class or create a persistence helper
class PageRefreshPersistence {
  static const String _navIndexKey = 'last_nav_index';
  
  static Future<void> saveNavIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_navIndexKey, index);
  }
  
  static Future<int> getLastNavIndex({int defaultIndex = 2}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_navIndexKey) ?? defaultIndex;
  }
}