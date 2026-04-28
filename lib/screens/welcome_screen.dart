import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khibarti/app.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/session_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/login_screen.dart';
import 'package:khibarti/widgets/khibarti_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _roleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedRole = 1;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _roleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _roleController,
      curve: Curves.easeOutCubic,
    ));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _mainController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _roleController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _changeLanguage(Locale locale) async {
    AppState.locale = locale;
    await SessionService.saveLocale(locale.languageCode);
    runApp(const KhibartiApp());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFBF5),
              const Color(0xFF1B5E57).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLanguageSelector(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const KhibartiLogo(size: 150),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        AppLocalizations.of(context).welcomeTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF1B5E57),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(flex: 2),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildRoleButtons(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAuthButtons(context),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final isAr = AppState.locale.languageCode == 'ar';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _changeLanguage(isAr ? const Locale('en') : const Locale('ar'));
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E57).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF1B5E57).withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 20,
                color: const Color(0xFF1B5E57),
              ),
              const SizedBox(width: 6),
              Text(
                isAr ? 'EN' : 'عربي',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B5E57),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoleButton(
          label: l10n.student,
          icon: Icons.school_outlined,
          roleId: 1,
          selected: _selectedRole == 1,
          onTap: () => setState(() => _selectedRole = 1),
        ),
        const SizedBox(width: 14),
        _RoleButton(
          label: l10n.expert,
          icon: Icons.person_outline,
          roleId: 2,
          selected: _selectedRole == 2,
          onTap: () => setState(() => _selectedRole = 2),
        ),
        const SizedBox(width: 14),
        _RoleButton(
          label: l10n.company,
          icon: Icons.business_outlined,
          roleId: 3,
          selected: _selectedRole == 3,
          onTap: () => setState(() => _selectedRole = 3),
        ),
      ],
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToLogin(isSignUp: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E57),
              foregroundColor: const Color(0xFFFFFBF0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 2,
              shadowColor: const Color(0xFF1B5E57).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(l10n.login),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _navigateToLogin(isSignUp: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B5E57),
              side: const BorderSide(color: Color(0xFF1B5E57), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(l10n.signUp),
          ),
        ),
      ],
    );
  }

  void _navigateToLogin({required bool isSignUp}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          isSignUp: isSignUp,
          roleId: _selectedRole,
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int roleId;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.roleId,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1B5E57).withOpacity(0.15)
              : const Color(0xFFFFFBF5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF1B5E57) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 34,
              weight: 600,
              color: const Color(0xFF1B5E57),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF1B5E57),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
