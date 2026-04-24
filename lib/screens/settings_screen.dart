import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:khibarti/app.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/services/session_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/login_screen.dart';
import 'package:khibarti/screens/welcome_screen.dart';
import 'package:khibarti/widgets/khibarti_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _accessibilityMode = false;
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _accessibilityMode = AppState.accessibilityMode;
  }

  void _rebuildApp() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      runApp(const KhibartiApp(skipWelcome: true));
    });
  }

  void _logout() async {
    AppState.currentUser = null;
    await SessionService.clearUser();
    if (!mounted) return;
    if (AppState.adminFlavor) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            isSignUp: false,
            roleId: 1,
            adminOnly: true,
          ),
        ),
        (_) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    }
  }

  void _deleteAccount() async {
    final role = AppState.currentUser?['role_name'] as String?;
    if (role == 'admin') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن حذف حساب المدير من التطبيق')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteAccount),
        content: const Text('هل أنت متأكد من حذف الحساب؟ سيتم فقدان جميع البيانات.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final userId = AppState.currentUser?['id'] as int?;
      if (userId != null) {
        await ApiService.instance.deleteUser(userId);
        AppState.currentUser = null;
        await SessionService.clearUser();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SettingsTile(
            icon: Icons.language,
            title: l10n.language,
            subtitle: AppState.locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
            onTap: () => _showLanguageDialog(context),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: l10n.notificationsSettings,
            subtitle: _notificationsOn ? l10n.notificationsOn : 'معطلة',
            onTap: () => setState(() => _notificationsOn = !_notificationsOn),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: () => _showPolicy(context),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: l10n.termsConditions,
            onTap: () => _showTerms(context),
          ),
          const Divider(height: 32),
          SwitchListTile(
            secondary: const Icon(Icons.accessibility_new, color: Color(0xFF1A1A1A)),
            title: Text(l10n.accessibility, style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
            subtitle: Text(l10n.accessibilityDesc, style: const TextStyle(color: Color(0xFF555555), fontSize: 14)),
            value: _accessibilityMode,
            onChanged: (v) async {
              setState(() => _accessibilityMode = v);
              AppState.accessibilityMode = v;
              await SessionService.saveAccessibility(v);
              _rebuildApp();
            },
          ),
          const Divider(height: 32),
          _ActionButton(
            icon: Icons.logout,
            label: l10n.logout,
            color: const Color(0xFFE65100),
            onTap: _logout,
          ),
          if (AppState.currentUser?['role_name'] != 'admin') ...[
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.delete_forever,
              label: l10n.deleteAccount,
              color: const Color(0xFFD32F2F),
              onTap: _deleteAccount,
            ),
          ],
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLang = AppState.locale.languageCode;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(
          textTheme: Theme.of(ctx).textTheme.apply(
            bodyColor: const Color(0xFF1A1A1A),
            displayColor: const Color(0xFF1A1A1A),
          ),
        ),
        child: AlertDialog(
          title: Text(l10n.language, style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Radio<String>(
                  value: 'ar',
                  groupValue: currentLang,
                  onChanged: (v) => _applyLanguage(ctx, 'ar'),
                ),
                title: const Text('العربية', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600)),
                onTap: () => _applyLanguage(ctx, 'ar'),
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'en',
                  groupValue: currentLang,
                  onChanged: (v) => _applyLanguage(ctx, 'en'),
                ),
                title: const Text('English', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600)),
                onTap: () => _applyLanguage(ctx, 'en'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel, style: const TextStyle(color: Color(0xFF1B5E57))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyLanguage(BuildContext ctx, String code) async {
    Navigator.pop(ctx);
    AppState.locale = Locale(code);
    await SessionService.saveLocale(code);
    _rebuildApp();
  }

  void _showPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).privacyPolicy, style: const TextStyle(color: Color(0xFF1A1A1A))),
        content: SingleChildScrollView(
          child: Text(
            'سياسة الخصوصية لتطبيق خبرتي:\n\n'
            '• نحن نحترم خصوصيتك ولا نشارك بياناتك مع أطراف ثالثة.\n'
            '• جميع البيانات مخزنة محلياً على جهازك فقط.\n'
            '• لا نستخدم أي خدمات خارجية أو سحابية.\n'
            '• يمكنك حذف حسابك في أي وقت من الإعدادات.',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Color(0xFF1B5E57), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).termsConditions, style: const TextStyle(color: Color(0xFF1A1A1A))),
        content: SingleChildScrollView(
          child: Text(
            'الشروط والأحكام لتطبيق خبرتي:\n\n'
            '• الاستخدام للأغراض التعليمية والتدريبية فقط.\n'
            '• الالتزام بأداب الحوار والاحترام خلال الجلسات.\n'
            '• التطبيق يعمل محلياً بدون إنترنت بعد التثبيت.\n'
            '• إدارة التطبيق غير مسؤولة عن محتوى الجلسات.',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Color(0xFF1B5E57), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(24),
      elevation: 1,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.4), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1A1A1A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: KhibartiCard.listItem(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E57).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1B5E57), size: 22),
          ),
          title: title,
          subtitle: subtitle,
          actions: null,
        ),
      ),
    );
  }
}
