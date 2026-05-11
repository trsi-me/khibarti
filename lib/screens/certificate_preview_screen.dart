import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// معاينة PDF داخل التطبيق (طباعة ومشاركة متاحة من شريط أدوات [PdfPreview]).
class CertificatePdfViewer extends StatelessWidget {
  final Uint8List pdfBytes;
  final String? pdfFileName;

  const CertificatePdfViewer({
    super.key,
    required this.pdfBytes,
    this.pdfFileName,
  });

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (format) async => pdfBytes,
      allowPrinting: true,
      allowSharing: true,
      canChangeOrientation: false,
      canChangePageFormat: false,
      pdfFileName: pdfFileName ?? 'certificate.pdf',
    );
  }
}

/// نافذة منبثقة تعرض الشهادة دون مغادرة الشاشة الحالية (ويب وموبايل).
Future<void> showCertificatePreviewDialog(
  BuildContext context, {
  required Uint8List pdfBytes,
  String title = 'الشهادة',
  String? pdfFileName,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      final w = math.min(560.0, size.width - 24);
      final h = size.height * 0.88;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: w,
          height: h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Theme.of(ctx).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 4, top: 4, bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(ctx).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: MaterialLocalizations.of(ctx).closeButtonTooltip,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Theme.of(ctx).dividerColor),
              Expanded(
                child: CertificatePdfViewer(
                  pdfBytes: pdfBytes,
                  pdfFileName: pdfFileName,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class CertificatePreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;
  final String? savedPathOrName;

  const CertificatePreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
    this.savedPathOrName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: CertificatePdfViewer(
        pdfBytes: pdfBytes,
        pdfFileName: savedPathOrName ?? title,
      ),
    );
  }
}
