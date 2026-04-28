// ملف للمتصفح فقط — مسارات عنوان حقيقية؛ تجاهل تحذير dart:html هنا مقابل تعقيد js_interop.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

/// يحدد لوحة الإدارة من عنوان الصفحة الفعلي.
///
/// لا يعتمد على [Uri.base]: في Wasm/compile للويب غالباً يكون `/` دائماً.
/// احتياطاً: لو بقي الوضع بدون PathUrlStrategy نتحقق من الهاش '#/admin'.
bool webUrlIndicatesAdminFlavor() {
  try {
    final pathname = html.window.location.pathname ?? '/';
    final parts = pathname.split('/').where((s) => s.isNotEmpty);
    if (parts.isNotEmpty && parts.first == 'admin') return true;

    final h = html.window.location.hash;
    return h == '#/admin' || h.startsWith('#/admin/');
  } catch (_) {
    return false;
  }
}
