import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/main_app.dart';
import 'package:khibarti/screens/login_screen.dart';
import 'package:khibarti/screens/welcome_screen.dart';
import 'package:khibarti/services/session_service.dart';
import 'package:khibarti/widgets/khibarti_logo.dart';
import 'package:khibarti/utils/accessibility_dim.dart';

/// شاشة البداية - تحميل الجلسة المحفوظة ثم الانتقال
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final user = await SessionService.loadUser();
    if (!mounted) return;

    if (AppState.adminFlavor) {
      if (user != null && user['role_name'] == 'admin') {
        AppState.currentUser = user;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainApp()),
        );
      } else {
        if (user != null) {
          await SessionService.clearUser();
          AppState.currentUser = null;
          if (!mounted) return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(
              isSignUp: false,
              roleId: 1,
              adminOnly: true,
            ),
          ),
        );
      }
      return;
    }

    if (user != null) {
      AppState.currentUser = user;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainApp()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              const Color(0xFF1B5E57).withOpacity(0.08),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: KhibartiLogo(size: 180.aks),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
