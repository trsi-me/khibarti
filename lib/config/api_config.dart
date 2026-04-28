import 'package:flutter/foundation.dart' show kIsWeb;

/// إعدادات الـ API
/// - **لوحة الإدارة من المتصفح**: ادخل `https://نطاقك/admin` (بدون `#`) بعد إعادة بناء الويب.
/// - **الويب على Render (نفس الرابط)**: [Uri.base.origin] تلقائياً.
/// - `flutter run -d chrome` مع سيرفر منفذ آخر: `--dart-define=API_BASE_URL=http://127.0.0.1:3000`
/// - **أندرويد**: محاكي `10.0.2.2:3000` | إنتاج: `--dart-define=API_BASE_URL=https://تطبيقك.onrender.com`
class ApiConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (kIsWeb) {
      if (fromEnv.isNotEmpty) return fromEnv;
      return Uri.base.origin;
    }
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'http://10.0.2.2:3000';
  }
}
