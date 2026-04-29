import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';

/// لوحة تحكم المدير — إحصائيات وإرسال إشعارات
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = ApiService.instance;
  Map<String, dynamic>? _stats;
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
    final data = await _api.getAdminStats(id);
    if (mounted) {
      setState(() {
        _stats = data;
        _loading = false;
      });
    }
  }

  String _num(dynamic v) {
    if (v == null) return '0';
    if (v is num) return v.round().toString();
    return v.toString();
  }

  Future<void> _showNotifyDialog() async {
    final l10n = AppLocalizations.of(context);
    final adminId = AppState.currentUser?['id'] as int?;
    if (adminId == null) return;

    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    var allUsers = true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(l10n.adminSendNotification),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminNotificationTitle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminNotificationBody,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(l10n.adminNotifyAll),
                      value: allUsers,
                      onChanged: (v) => setLocal(() {
                        allUsers = v;
                      }),
                    ),
                    if (!allUsers)
                      TextField(
                        controller: userIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'User ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textDirection: TextDirection.ltr,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.send),
                ),
              ],
            );
          },
        );
      },
    );

    final title = titleCtrl.text.trim();
    final bodyText = bodyCtrl.text.trim();
    final userIdStr = userIdCtrl.text.trim();
    titleCtrl.dispose();
    bodyCtrl.dispose();
    userIdCtrl.dispose();

    if (ok != true || !mounted) return;
    if (title.isEmpty) return;
    int? targetUserId;
    if (!allUsers) {
      targetUserId = int.tryParse(userIdStr);
      if (targetUserId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('أدخل رقم مستخدم صالح')));
        return;
      }
    }
    final success = await _api.sendAdminNotification(
      adminUserId: adminId,
      title: title,
      body: bodyText.isEmpty ? null : bodyText,
      userId: targetUserId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم إرسال الإشعار' : 'فشل الإرسال'),
        backgroundColor: success ? AppColors.primary : Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPanelTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNotifyDialog,
        icon: const Icon(Icons.notifications_active_outlined),
        label: Text(l10n.adminSendNotification),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _stats == null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.adminServerError,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.adminOverview,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, c) {
                        final w = (c.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: w,
                              child: KhibartiCard.stat(
                                icon: Icons.people_outline,
                                value: _num(_stats!['totalUsers']),
                                label: l10n.navAdminUsers,
                              ),
                            ),
                            SizedBox(
                              width: w,
                              child: KhibartiCard.stat(
                                icon: Icons.event_note,
                                value: _num(_stats!['totalSessions']),
                                label: l10n.navSessions,
                              ),
                            ),
                            SizedBox(
                              width: w,
                              child: KhibartiCard.stat(
                                icon: Icons.chat_bubble_outline,
                                value: _num(_stats!['totalMessages']),
                                label: l10n.chat,
                                iconColor: AppColors.darkBlue,
                              ),
                            ),
                            SizedBox(
                              width: w,
                              child: KhibartiCard.stat(
                                icon: Icons.notifications_none,
                                value: _num(_stats!['totalNotifications']),
                                label: l10n.notifications,
                                iconColor: AppColors.accent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isAr(context) ? 'المستخدمون حسب الدور' : 'Users by role',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            for (final row
                                in (_stats!['byRole'] as List<dynamic>? ?? []))
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _roleLabel(
                                        context,
                                        row['role']?.toString() ?? '',
                                      ),
                                    ),
                                    Chip(
                                      label: Text(_num(row['c'])),
                                      backgroundColor: AppColors.primary
                                          .withOpacity(0.12),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr(context)
                          ? 'الجلسات حسب الحالة'
                          : 'Sessions by status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            for (final row
                                in (_stats!['sessionsByStatus']
                                        as List<dynamic>? ??
                                    []))
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _statusLabel(
                                        context,
                                        row['status']?.toString() ?? '',
                                      ),
                                    ),
                                    Chip(
                                      label: Text(_num(row['c'])),
                                      backgroundColor: AppColors.accent
                                          .withOpacity(0.15),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  bool isAr(BuildContext context) => AppLocalizations.of(context).isAr;

  String _roleLabel(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context);
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

  String _statusLabel(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'upcoming':
        return l10n.tabUpcoming;
      case 'completed':
        return l10n.tabCompleted;
      case 'cancelled':
        return l10n.tabCancelled;
      default:
        return status;
    }
  }
}
