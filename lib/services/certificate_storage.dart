import 'dart:typed_data';

import 'certificate_storage_stub.dart'
    if (dart.library.html) 'certificate_storage_web.dart'
    if (dart.library.io) 'certificate_storage_io.dart';

abstract class CertificateStorage {
  Future<String?> savePdf({required Uint8List bytes, required String fileName});
  Future<void> printPdf({required Uint8List bytes, required String fileName});
}

CertificateStorage getCertificateStorage() => createCertificateStorage();

final CertificateStorage certificateStorage = getCertificateStorage();

