import 'package:shared_preferences/shared_preferences.dart';

class AdminPreferences {
  static const String keyAdminToken = 'admin_auth_token';
  static const String keyAdminId = 'admin_id';
  static const String keyAdminEmail = 'admin_email';

  static Future<void> saveAdminToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAdminToken, token);
  }

  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAdminToken);
  }

  static Future<void> saveAdminInfo(String id, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAdminId, id);
    await prefs.setString(keyAdminEmail, email);
  }

  static Future<void> clearAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyAdminToken);
    await prefs.remove(keyAdminId);
    await prefs.remove(keyAdminEmail);
  }
}
