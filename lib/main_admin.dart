import 'package:flutter/material.dart';
import 'package:khibarti/app.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/session_service.dart';

/// نقطة دخول **تطبيق الإدارة فقط** — شغّل: `flutter run -t lib/main_admin.dart`
/// لا يعرض رابط إدارة في التطبيق العام؛ تفتح مباشرة على تسجيل دخول المدير بعد الـ Splash.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppState.adminFlavor = true;
  AppState.locale = Locale(await SessionService.loadLocale());
  AppState.accessibilityMode = await SessionService.loadAccessibility();
  runApp(const KhibartiApp());
}
