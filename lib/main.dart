import 'package:flutter/material.dart';
import 'package:khibarti/app.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppState.adminFlavor = false;
  AppState.locale = Locale(await SessionService.loadLocale());
  AppState.accessibilityMode = await SessionService.loadAccessibility();
  runApp(const KhibartiApp());
}
