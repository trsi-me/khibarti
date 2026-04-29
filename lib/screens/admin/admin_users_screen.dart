import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/admin/admin_user_detail_screen.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';

/// قائمة جميع مستخدمي المنصة للمدير — بطاقات بتصميم موحّد (بدون شريط جانبي)
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _api = ApiService.instance;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = AppState.currentUser?['id'] as int?;
    if (id == null) return;
    setState(() => _loading = true);
    final list = await _api.getAdminUsers(id);
    if (mounted) {
      setState(() {
        _users = list;
        _loading = false;
      });
    }
  }

  String _roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'student':
        return l10n.student;
      case 'expert':
        return l10n.expert;
      case 'company':
        return l10n.company;
      case 'company_manager':
        return l10n.companyManager;
      case 'company_delegate':
        return l10n.companyDelegate;
      case 'admin':
        return l10n.roleAdmin;
      default:
        return role;
    }
  }

  int _parseUserId(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse('$raw') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUsersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context, l10n),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(l10n.adminAddUser),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _users.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(child: Text(l10n.adminServerError)),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: _users.length,
                itemBuilder: (context, i) {
                  final u = _users[i];
                  final name = u['name']?.toString() ?? '';
                  final email = u['email']?.toString() ?? '';
                  final role = u['role_name']?.toString() ?? '';
                  final uid = _parseUserId(u['id']);
                  final phone = u['phone']?.toString();
                  final blocked =
                      u['is_blocked'] == 1 || u['is_blocked'] == true;
                  final expertVerified = role == 'expert' &&
                      (u['expert_verified'] == 1 || u['expert_verified'] == true);

                  final subLines = <String>[email];
                  if (phone != null && phone.isNotEmpty) subLines.add(phone);
                  if (blocked) subLines.add(l10n.adminUserRestricted);
                  subLines.add('#$uid');

                  return KhibartiCard.listItem(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: name.isEmpty ? '—' : name,
                    subtitle: subLines.join('\n'),
                    actions: [
                      Chip(
                        label: Text(
                          _roleLabel(l10n, role),
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      ),
                      if (blocked)
                        Chip(
                          label: Text(
                            l10n.adminUserRestricted,
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.orange.shade50,
                        ),
                      if (expertVerified)
                        Chip(
                          avatar: Icon(Icons.verified_rounded, size: 16, color: Colors.teal.shade800),
                          label: Text(
                            l10n.expertVerifiedBadge,
                            style: TextStyle(fontSize: 11, color: Colors.teal.shade900),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.teal.shade50,
                        ),
                    ],
                    onTap: () async {
                      if (uid < 1) return;
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminUserDetailScreen(userId: uid),
                        ),
                      );
                      if (mounted) _load();
                    },
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context, AppLocalizations l10n) async {
    final adminId = AppState.currentUser?['id'] as int?;
    if (adminId == null) return;

    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final roleVN = ValueNotifier<int>(1);

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) {
          return ValueListenableBuilder<int>(
            valueListenable: roleVN,
            builder: (_, roleId, __) {
              return AlertDialog(
                title: Text(l10n.adminAddUser),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.name,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          hintText: l10n.adminAddUserHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: roleId,
                        decoration: InputDecoration(
                          labelText: l10n.isAr ? 'الدور' : 'Role',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          DropdownMenuItem(value: 1, child: Text(l10n.student)),
                          DropdownMenuItem(value: 2, child: Text(l10n.expert)),
                          DropdownMenuItem(value: 3, child: Text(l10n.company)),
                        ],
                        onChanged: (v) {
                          if (v != null) roleVN.value = v;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      final pass = passCtrl.text;
                      if (name.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(dialogCtx).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.isAr ? 'الاسم والمعرّف مطلوبان' : 'Name and login id required',
                            ),
                          ),
                        );
                        return;
                      }
                      if (pass.length < 6) {
                        ScaffoldMessenger.of(dialogCtx).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.isAr ? 'كلمة المرور 6 أحرف على الأقل' : 'Password at least 6 characters',
                            ),
                          ),
                        );
                        return;
                      }
                      try {
                        await _api.adminCreateUser(
                          adminId,
                          email: email,
                          password: pass,
                          name: name,
                          roleId: roleVN.value,
                        );
                        if (!dialogCtx.mounted) return;
                        Navigator.pop(dialogCtx);
                        if (context.mounted) {
                          _load();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.adminUserSaved)),
                          );
                        }
                      } on ApiException catch (e) {
                        if (dialogCtx.mounted) {
                          ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text(e.message)));
                        }
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text(l10n.adminCreateUserSubmit),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameCtrl.dispose();
      emailCtrl.dispose();
      passCtrl.dispose();
      roleVN.dispose();
    }
  }
}
