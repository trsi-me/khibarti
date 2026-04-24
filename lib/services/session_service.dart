import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// حفظ واسترجاع جلسة المستخدم — يبقى مسجّل الدخول بعد إعادة التشغيل
class SessionService {
  static const String _keyUser = 'khibarti_current_user';
  static const String _keyLocale = 'khibarti_locale';
  static const String _keyAccessibility = 'khibarti_accessibility';

  /// حفظ المستخدم الحالي
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  /// تحميل المستخدم المحفوظ
  static Future<Map<String, dynamic>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUser);
    if (json == null || json.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(json) as Map);
    } catch (_) {
      return null;
    }
  }

  /// مسح الجلسة (عند تسجيل الخروج أو حذف الحساب)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  /// حفظ اللغة
  static Future<void> saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, code);
  }

  /// تحميل اللغة
  static Future<String> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocale) ?? 'ar';
  }

  /// حفظ وضع الإعاقة
  static Future<void> saveAccessibility(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAccessibility, value);
  }

  /// تحميل وضع الإعاقة
  static Future<bool> loadAccessibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAccessibility) ?? false;
  }
}
