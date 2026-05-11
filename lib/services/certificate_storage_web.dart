import 'dart:async';
import 'dart:typed_data';

import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'certificate_storage.dart';

CertificateStorage createCertificateStorage() => _WebCertificateStorage();

class _WebCertificateStorage implements CertificateStorage {
  @override
  Future<String?> savePdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final a = html.AnchorElement(href: url)
        ..download = fileName
        ..style.display = 'none';

      html.document.body?.append(a);
      a.click();
      a.remove();

      // اترك وقت بسيط قبل revoke حتى لا يفشل التحميل في بعض المتصفحات.
      Timer(const Duration(seconds: 1), () => html.Url.revokeObjectUrl(url));
      return fileName;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> printPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final blob = html.Blob([bytes], 'application/pdf');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    // طباعة من نفس الصفحة عبر iframe مخفي (أكثر توافقًا مع أنواع Dart الحديثة).
    final iframe = html.IFrameElement()
      ..style.border = '0'
      ..style.width = '0'
      ..style.height = '0'
      ..style.position = 'fixed'
      ..style.right = '0'
      ..style.bottom = '0'
      ..src = blobUrl;

    final completer = Completer<void>();

    void cleanup() {
      try {
        iframe.remove();
      } catch (_) {}
      Timer(
        const Duration(seconds: 1),
        () => html.Url.revokeObjectUrl(blobUrl),
      );
    }

    iframe.onLoad.listen((_) {
      try {
        final w = iframe.contentWindow;
        if (w != null) {
          js_util.callMethod(w, 'focus', const []);
          js_util.callMethod(w, 'print', const []);
        } else {
          html.window.open(blobUrl, '_blank');
        }
      } catch (_) {
        // fallback: افتح الـ PDF مباشرة (المستخدم يضغط Print من المتصفح)
        html.window.open(blobUrl, '_blank');
      } finally {
        cleanup();
        if (!completer.isCompleted) completer.complete();
      }
    });

    html.document.body?.append(iframe);

    // لو ما اشتغل onLoad لأي سبب، لا نترك blob URL للأبد.
    Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        cleanup();
        completer.complete();
      }
    });

    return completer.future;
  }
}
