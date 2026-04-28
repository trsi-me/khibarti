import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// روابط نظيفة بدون `#` حتى يعمل `/admin` كمسار حقيقي في الشريط.
void configureAppUrlStrategy() {
  usePathUrlStrategy();
}
