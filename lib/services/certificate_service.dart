import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// توليد وحفظ شهادات الخبرة محلياً
class CertificateService {
  static Future<String?> generateAndSave({
    required String expertName,
    required String specialty,
    required String sessionDate,
    required String userName,
  }) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('شهادة خبرة', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.Text('تُمنح هذه الشهادة إلى', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text(userName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('لإكمال جلسة تدريب مع الخبير', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
              pw.Text(expertName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('في تخصص: $specialty', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 16),
              pw.Text('تاريخ الجلسة: $sessionDate', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 32),
              pw.Text('Khibarti', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'certificate_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
