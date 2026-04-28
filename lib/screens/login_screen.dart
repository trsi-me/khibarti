import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/main_app.dart';
import 'package:khibarti/screens/welcome_screen.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/services/session_service.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUp;
  final int roleId;

  /// وضع تطبيق الإدارة فقط — لا تسجيل، والدخول يقبل حساب `admin` فقط
  final bool adminOnly;

  const LoginScreen({
    super.key,
    required this.isSignUp,
    required this.roleId,
    this.adminOnly = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _api = ApiService.instance;
  bool _loading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final signUp = widget.adminOnly ? false : widget.isSignUp;
    if (signUp && !_acceptedTerms) {
      _showSnack(AppLocalizations.of(context).agreeToTermsError);
      return;
    }
    setState(() => _loading = true);

    if (signUp) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      if (await _api.emailExists(email)) {
        if (mounted) _showSnack('البريد الإلكتروني مستخدم مسبقاً');
        setState(() => _loading = false);
        return;
      }
      final user = await _api.register(
        email: email,
        password: password,
        roleId: widget.roleId,
        name: name,
      );
      if (user != null) {
        AppState.currentUser = user;
        await SessionService.saveUser(user);
        if (mounted) _navigateToMainApp();
      } else {
        if (mounted) _showSnack('حدث خطأ أثناء التسجيل');
      }
    } else {
      final user = await _api.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (user != null) {
        if (widget.adminOnly && user['role_name'] != 'admin') {
          if (mounted) {
            _showSnack('يجب تسجيل الدخول بحساب مدير — هذا الحساب ليس مديراً');
          }
        } else {
          AppState.currentUser = user;
          await SessionService.saveUser(user);
          if (mounted) _navigateToMainApp();
        }
      } else {
        if (mounted) _showSnack('البريد الإلكتروني أو كلمة المرور غير صحيحة - تأكد من تشغيل السيرفر');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainApp()),
    );
  }

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signUp = widget.adminOnly ? false : widget.isSignUp;
    final title = widget.adminOnly
        ? l10n.adminPanelTitle
        : (signUp ? l10n.signUpTitle : l10n.loginTitle);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (signUp) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    textDirection: TextDirection.rtl,
                    validator: (v) => v == null || v.trim().isEmpty ? 'أدخل الاسم' : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: 'example@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  validator: (v) => v == null || v.trim().isEmpty ? 'أدخل البريد الإلكتروني' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  textDirection: TextDirection.ltr,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                    if (signUp && v.length < 6) return 'كلمة المرور 6 أحرف على الأقل';
                    return null;
                  },
                ),
                if (signUp) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    textDirection: TextDirection.ltr,
                    validator: (v) => v != _passwordController.text ? 'كلمتا المرور غير متطابقتين' : null,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      AppLocalizations.of(context).agreeToTerms,
                      style: const TextStyle(fontSize: 14, height: 1.3),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFBF0))) : Text(signUp ? l10n.createAccount : l10n.enter),
                  ),
                ),
                if (!widget.adminOnly) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _navigateToWelcome,
                    icon: const Icon(Icons.home_outlined, size: 20),
                    label: Text(l10n.backToHome),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E57),
                      side: const BorderSide(color: Color(0xFF1B5E57)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
