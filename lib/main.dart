import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:khibarti/app.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/session_service.dart';

import 'url_strategy_stub.dart'
    if (dart.library.html) 'url_strategy_web.dart' as url_strategy;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  url_strategy.configureAppUrlStrategy();

  var adminFlavor = false;
  if (kIsWeb) {
    final path = Uri.base.path;
    adminFlavor = path == '/admin' ||
        path.startsWith('/admin/'); // مثل /admin أي شيء تحت نفس المسار
  }
  AppState.adminFlavor = adminFlavor;

  AppState.locale = Locale(await SessionService.loadLocale());
  AppState.accessibilityMode = await SessionService.loadAccessibility();
  runApp(const KhibartiApp());
}
