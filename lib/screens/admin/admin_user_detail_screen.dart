import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/theme/app_theme.dart';

/// تفاصيل مستخدم + تعديل / تقييد / حذف (للمدير فقط)
class AdminUserDetailScreen extends StatefulWidget {
  final int userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final _api = ApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  Map<String, dynamic>? _data;
  bool _blocked = false;
  int? _roleId;
  String? _roleName;
  String? _createdAt;
  bool _expertVerified = false;

  InputDecoration _fieldDec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final adminId = AppState.currentUser?['id'] as int?;
    if (adminId == null) return;
    setState(() => _loading = true);
    final d = await _api.getAdminUserDetail(adminId, widget.userId);
    if (!mounted) return;
    if (d == null) {
      setState(() {
        _loading = false;
        _data = null;
      });
      return;
    }
    _nameCtrl.text = d['name']?.toString() ?? '';
    _emailCtrl.text = d['email']?.toString() ?? '';
    _phoneCtrl.text = d['phone']?.toString() ?? '';
    _countryCtrl.text = d['country']?.toString() ?? '';
    _passwordCtrl.clear();
    final ib = d['is_blocked'];
    _blocked = ib == 1 || ib == true;
    _roleId = d['role_id'] is int ? d['role_id'] as int : int.tryParse('${d['role_id']}');
    _roleName = d['role_name']?.toString();
    _createdAt = d['created_at']?.toString();
    final ev = d['expert_verified'];
    _expertVerified = ev == 1 || ev == true;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  bool get _isTargetAdmin => _roleName == 'admin';

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final adminId = AppState.currentUser?['id'] as int?;
    if (adminId == null) return;
    setState(() => _saving = true);
    try {
      await _api.adminUpdateUser(
        adminId,
        widget.userId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        password: _passwordCtrl.text.trim().isNotEmpty ? _passwordCtrl.text : null,
        roleId: _isTargetAdmin ? null : _roleId,
        isBlocked: _blocked,
        expertVerified: (!_isTargetAdmin && _roleId == 2) ? _expertVerified : null,
      );
      _passwordCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminUserSaved)),
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final adminId = AppState.currentUser?['id'] as int?;
    if (adminId == null) return;
    if (adminId == widget.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminCannotDeleteSelf)),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.adminDeleteUserConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final deleted = await _api.adminDeleteUser(adminId, widget.userId);
    if (!mounted) return;
    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminUserDeleted)),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminServerError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUserDetail)),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _data == null
          ? Center(child: Text(l10n.adminServerError))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_createdAt != null && _createdAt!.isNotEmpty)
                    Text(
                      '${l10n.createdAt}: $_createdAt',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameCtrl,
                    decoration: _fieldDec(l10n.name),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.text,
                    decoration: _fieldDec(l10n.email, hint: l10n.adminAddUserHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDec(l10n.phone),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _countryCtrl,
                    decoration: _fieldDec(l10n.country),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: _fieldDec(
                      l10n.changePassword,
                      hint: l10n.isAr ? 'اتركه فارغاً إن لم ترد التغيير' : 'Leave empty to keep',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isTargetAdmin)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.roleAdmin,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Text(
                      l10n.adminRoleChangeHint,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _roleId != null && [1, 2, 3, 5].contains(_roleId) ? _roleId : 1,
                      decoration: _fieldDec(l10n.isAr ? 'الدور' : 'Role'),
                      items: [
                        DropdownMenuItem(value: 1, child: Text(l10n.student)),
                        DropdownMenuItem(value: 2, child: Text(l10n.expert)),
                        DropdownMenuItem(value: 3, child: Text(l10n.company)),
                        DropdownMenuItem(value: 5, child: Text(l10n.companyManager)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _roleId = v);
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (!_isTargetAdmin && _roleId == 2)
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: SwitchListTile(
                        value: _expertVerified,
                        onChanged: (v) {
                          HapticFeedback.lightImpact();
                          setState(() => _expertVerified = v);
                        },
                        title: Text(l10n.expertVerifiedToggle),
                        subtitle: Text(l10n.expertVerifiedDesc),
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primary;
                          }
                          return null;
                        }),
                        secondary: Icon(
                          Icons.verified_rounded,
                          color: _expertVerified ? AppColors.primary : Colors.grey,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
                        ),
                      ),
                    ),
                  if (!_isTargetAdmin && _roleId == 2) const SizedBox(height: 12),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: SwitchListTile(
                      value: _blocked,
                      onChanged: _isTargetAdmin
                          ? null
                          : (v) {
                              HapticFeedback.lightImpact();
                              setState(() => _blocked = v);
                            },
                      title: Text(l10n.adminRestrictAccount),
                      subtitle: Text(_blocked ? l10n.adminUserRestricted : l10n.adminUserActive),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }
                        return null;
                      }),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(l10n.adminSaveChanges),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _confirmDelete,
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700),
                    label: Text(
                      l10n.deleteAccount,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
