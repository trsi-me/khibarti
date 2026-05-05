import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:khibarti/app.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/session_service.dart';

import 'url_strategy_stub.dart'
    if (dart.library.html) 'url_strategy_web.dart' as url_strategy;
import 'web_location_path_stub.dart'
    if (dart.library.html) 'web_location_path_web.dart' as web_location_path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  url_strategy.configureAppUrlStrategy();

  var adminFlavor = false;
  if (kIsWeb) {
    adminFlavor = web_location_path.webUrlIndicatesAdminFlavor();
  }
  AppState.adminFlavor = adminFlavor;

  AppState.locale = Locale(await SessionService.loadLocale());
  AppState.accessibilityMode = await SessionService.loadAccessibility();
  runApp(KhibartiApp());
}
