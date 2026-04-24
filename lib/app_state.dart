import 'package:flutter/material.dart';

/// حالة التطبيق - المستخدم الحالي والتصميم
class AppState {
  static bool accessibilityMode = false;
  static Locale locale = const Locale('ar');
  static Map<String, dynamic>? currentUser;

  /// يُضبط من [main_admin.dart] — تجربة إدارة منفصلة (بدون رابط من التطبيق العام)
  static bool adminFlavor = false;
}
