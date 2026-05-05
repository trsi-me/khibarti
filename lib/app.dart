import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/main_app.dart';
import 'package:khibarti/screens/splash_screen.dart';
import 'package:khibarti/theme/app_theme.dart';

class KhibartiApp extends StatelessWidget {
  final bool skipWelcome;

  const KhibartiApp({super.key, this.skipWelcome = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppState.adminFlavor ? 'Khibarti Admin' : 'خبرتي | Khibarti',
      theme: AppTheme.lightTheme(
        accessibilityIconFactor:
            AppState.accessibilityMode ? AppState.accessibilityUIScale : 1.0,
      ),
      locale: AppState.locale,
      localeResolutionCallback: (_, supported) => AppState.locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      key: ValueKey(
        'app_${AppState.locale.languageCode}_${AppState.adminFlavor}_${AppState.accessibilityMode}_${AppState.accessibilityGeneration}',
      ),
      builder: (context, child) {
        final wrapped = child ?? const SizedBox.shrink();
        if (!AppState.accessibilityMode) return wrapped;

        // من العرض مباشرة — لا نعتمد على MediaQuery الموروث حتى لا يُضاعَف عامل النص بعد OFF ثم ON.
        final platformMq = MediaQueryData.fromView(View.of(context));
        final linear = platformMq.textScaler.scale(14) / 14;
        return MediaQuery(
          data: platformMq.copyWith(
            textScaler:
                TextScaler.linear(linear * AppState.accessibilityUIScale),
          ),
          child: wrapped,
        );
      },
      home: skipWelcome ? const MainApp() : const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
