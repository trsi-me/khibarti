import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime? parseSessionDate(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return null;
  try {
    return DateTime.parse(dateStr.trim());
  } catch (_) {
    return null;
  }
}

/// يوم الأسبوع، التاريخ، والوقت — للجلسة القادمة
String formatSessionWhen(
  String dateStr,
  String timeStr,
  Locale locale,
) {
  final d = parseSessionDate(dateStr);
  final time = timeStr.trim();
  if (d == null) {
    return time.isEmpty ? dateStr : '$dateStr • $time';
  }
  final isAr = locale.languageCode == 'ar';
  final loc = isAr ? 'ar' : 'en';
  final weekday = DateFormat.EEEE(loc).format(d);
  final datePart = DateFormat.yMMMEd(loc).format(d);
  if (time.isEmpty) return '$weekday • $datePart';
  return '$weekday • $datePart • $time';
}
