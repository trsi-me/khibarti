import 'package:flutter/material.dart';
import 'package:khibarti/app.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/session_service.dart';

import 'url_strategy_stub.dart'
    if (dart.library.html) 'url_strategy_web.dart' as url_strategy;

/// نقطة دخول **تطبيق الإدارة فقط** — شغّل: `flutter run -t lib/main_admin.dart`
/// على الويب الأفضل الرابط: `/admin` (انظر [main.dart]).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  url_strategy.configureAppUrlStrategy();
  AppState.adminFlavor = true;
  AppState.locale = Locale(await SessionService.loadLocale());
  AppState.accessibilityMode = await SessionService.loadAccessibility();
  runApp(const KhibartiApp());
}
