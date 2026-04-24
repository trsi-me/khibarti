import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// شعار التطبيق - يحمل Logo.jpg من assets/images/ أو يعرض الشعار النصي كبديل
class KhibartiLogo extends StatelessWidget {
  final double size;

  const KhibartiLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        'assets/images/Logo.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildTextLogo(size),
      ),
    );
  }

  static Widget _buildTextLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5E57),
            Color(0xFF1565C0),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E57).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'خبرتي',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: size * 0.38,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFBF0),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Khibarti',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: size * 0.2,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE8E4DC),
            ),
          ),
        ],
      ),
    );
  }
}
