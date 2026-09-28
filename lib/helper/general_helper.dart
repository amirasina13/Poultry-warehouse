import 'package:shared_preferences/shared_preferences.dart';

class GeneralHelper {
  static const String _installDateKey = "install_date";

  /// Save install date (only if not already saved)
  static Future<void> saveFirstInstallDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_installDateKey)) {
      final now = DateTime.now().toIso8601String();
      await prefs.setString(_installDateKey, now);
      // print("Saved first install date: $now");
    }
  }

  /// Get saved install date
  static Future<String?> getInstallDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_installDateKey);

    if (dateString != null) {
      return dateString;
    }
    return null;
  }
}
