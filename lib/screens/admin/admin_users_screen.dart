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
}
