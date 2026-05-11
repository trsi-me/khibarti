import 'dart:typed_data';

import 'certificate_storage.dart';

CertificateStorage createCertificateStorage() => _UnsupportedCertificateStorage();

class _UnsupportedCertificateStorage implements CertificateStorage {
  @override
  Future<String?> savePdf({required Uint8List bytes, required String fileName}) async {
    return null;
  }

  @override
  Future<void> printPdf({required Uint8List bytes, required String fileName}) async {
    // no-op
  }
}

