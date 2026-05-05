import 'package:flutter/material.dart';

/// حالة التطبيق - المستخدم الحالي والتصميم
class AppState {
  static bool accessibilityMode = false;

  /// يزيد عند كل تبديل لوضع الاحتياجات الخاصة حتى يختلف [ValueKey] على [MaterialApp] ولا يُعاد استخدام عنصر قديم بعد OFF→ON.
  static int accessibilityGeneration = 0;

  /// عامل التكبير لوضع الاحتياجات الخاصة (مع إعدادات النظام للخط): يُستخدم مع [TextScaler] وأحجام الأيقونات/الصور عبر `*.aks` في `accessibility_dim.dart` — دون تعديل مسافات التخطيط (padding/margin).
  static const double accessibilityUIScale = 1.22;

  static Locale locale = const Locale('ar');
  static Map<String, dynamic>? currentUser;

  /// يُضبط من [main_admin.dart] — تجربة إدارة منفصلة (بدون رابط من التطبيق العام)
  static bool adminFlavor = false;
}
