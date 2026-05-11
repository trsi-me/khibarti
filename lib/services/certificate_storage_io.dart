import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'certificate_storage.dart';

CertificateStorage createCertificateStorage() => _IoCertificateStorage();

class _IoCertificateStorage implements CertificateStorage {
  @override
  Future<String?> savePdf({required Uint8List bytes, required String fileName}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> printPdf({required Uint8List bytes, required String fileName}) async {
    // على الأجهزة: نحفظ الملف فقط (الطباعة تختلف حسب النظام/التطبيق).
    await savePdf(bytes: bytes, fileName: fileName);
  }
}

