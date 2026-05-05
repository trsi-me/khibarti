import 'package:khibarti/app_state.dart';

/// تكبير أبعاد عنصر (أيقونة، نصف قطر صورة، إلخ) لوضع الاحتياجات الخاصة فقط.
/// لا يُستخدم لهوامش الشاشة أو [Padding]/[margin] العامة.
extension AccessibilityDim on num {
  double get aks =>
      AppState.accessibilityMode ? toDouble() * AppState.accessibilityUIScale : toDouble();
}
