import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'certificate_storage.dart';

/// ألوان هوية Khibarti (مطابقة لـ [AppColors] في التطبيق)
class _CertPalette {
  static final PdfColor primary = PdfColor.fromInt(0xFF1B5E57);
  static final PdfColor primaryDark = PdfColor.fromInt(0xFF0D3D38);
  static final PdfColor accent = PdfColor.fromInt(0xFF2E7D6E);
  static final PdfColor cream = PdfColor.fromInt(0xFFFFFBF0);
  static final PdfColor text = PdfColor.fromInt(0xFF1A1A1A);
  static final PdfColor muted = PdfColor.fromInt(0xFF555555);
}

/// توليد شهادة PDF، ثم حفظها/طباعتها حسب المنصة.
///
/// **اتجاه RTL على مستوى الصفحة** ضروري حتى تطبّق حزمة `pdf` تشكيل العربية
/// أو خوارزمية البيدي (انظر `use_arabic` / `use_bidi` في توثيق الحزمة).
class CertificateService {
  static Future<Uint8List?> generatePdfBytes({
    required String expertName,
    required String specialty,
    required String sessionDate,
    required String userName,
  }) async {
    try {
      // نفس عائلة الخط في التطبيق (IBM Plex Sans Arabic)
      final fontRegular = await PdfGoogleFonts.iBMPlexSansArabicRegular();
      final fontBold = await PdfGoogleFonts.iBMPlexSansArabicBold();

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
      );

      pw.TextStyle t(
        double size, {
        bool bold = false,
        PdfColor? color,
        double letterSpacing = 0,
      }) =>
          pw.TextStyle(
            fontSize: size,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? _CertPalette.text,
            letterSpacing: letterSpacing,
          );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          textDirection: pw.TextDirection.rtl,
          build: (ctx) => pw.Container(
            color: _CertPalette.cream,
            child: pw.Center(
              child: pw.Container(
                constraints: const pw.BoxConstraints(maxWidth: 480),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: _CertPalette.primary, width: 2.5),
                  boxShadow: [
                    pw.BoxShadow(
                      color: _CertPalette.primaryDark,
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const PdfPoint(0, 4),
                    ),
                  ],
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _CertPalette.primary,
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(4),
                          topRight: pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'شهادة خبرة',
                            textAlign: pw.TextAlign.center,
                            style: t(26, bold: true, color: _CertPalette.cream),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Container(
                            height: 3,
                            margin: const pw.EdgeInsets.symmetric(horizontal: 48),
                            decoration: pw.BoxDecoration(
                              color: _CertPalette.accent,
                              borderRadius: pw.BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(28, 28, 28, 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'تُمنح هذه الشهادة إلى',
                            textAlign: pw.TextAlign.center,
                            style: t(15, color: _CertPalette.muted),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            userName,
                            textAlign: pw.TextAlign.center,
                            style: t(22, bold: true),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text(
                            'لإكمال جلسة تدريب مع الخبير',
                            textAlign: pw.TextAlign.center,
                            style: t(14, color: _CertPalette.muted),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            expertName,
                            textAlign: pw.TextAlign.center,
                            style: t(18, bold: true, color: _CertPalette.primaryDark),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'في تخصص: $specialty',
                            textAlign: pw.TextAlign.center,
                            style: t(14),
                          ),
                          pw.SizedBox(height: 18),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'تاريخ الجلسة:',
                                style: t(12, color: _CertPalette.muted),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Directionality(
                                textDirection: pw.TextDirection.ltr,
                                child: pw.Text(
                                  sessionDate,
                                  style: t(12, color: _CertPalette.muted),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _CertPalette.cream,
                        border: pw.Border(
                          top: pw.BorderSide(
                            color: _CertPalette.accent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Directionality(
                            textDirection: pw.TextDirection.ltr,
                            child: pw.Text(
                              'Khibarti',
                              style: t(
                                13,
                                bold: true,
                                color: _CertPalette.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return Uint8List.fromList(await pdf.save());
    } catch (_) {
      return null;
    }
  }

  /// يحفظ الشهادة (تحميل في الويب، ملف محلي في الأجهزة) ويرجع المسار/الاسم.
  static Future<String?> generateAndSave({
    required String expertName,
    required String specialty,
    required String sessionDate,
    required String userName,
  }) async {
    final bytes = await generatePdfBytes(
      expertName: expertName,
      specialty: specialty,
      sessionDate: sessionDate,
      userName: userName,
    );
    if (bytes == null) return null;

    final fileName = 'certificate_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return certificateStorage.savePdf(bytes: bytes, fileName: fileName);
  }

  /// للويب: يفتح نافذة طباعة فعلية للشهادة (أو تبويب PDF مع زر Print).
  static Future<bool> generateAndPrint({
    required String expertName,
    required String specialty,
    required String sessionDate,
    required String userName,
  }) async {
    final bytes = await generatePdfBytes(
      expertName: expertName,
      specialty: specialty,
      sessionDate: sessionDate,
      userName: userName,
    );
    if (bytes == null) return false;

    final fileName = 'certificate_${DateTime.now().millisecondsSinceEpoch}.pdf';

    bool printed = false;
    try {
      printed = (await Printing.layoutPdf(onLayout: (_) async => bytes)) == true;
    } on MissingPluginException {
      printed = false;
    } catch (_) {
      printed = false;
    }

    if (printed) return true;

    try {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return false;
    } catch (_) {
      await certificateStorage.savePdf(bytes: bytes, fileName: fileName);
      return false;
    }
  }
}
