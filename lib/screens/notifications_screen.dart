import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';

/// شاشة الإشعارات — تعرض جميع إشعارات المستخدم
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService.instance;
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;
    final list = await _api.getNotificationsForUser(userId);
    if (mounted) {
      setState(() {
        _notifications = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: KhibartiCard.empty(
                      message: l10n.noNotifications,
                      icon: Icons.notifications_none_rounded,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, i) {
                      final n = _notifications[i];
                      return KhibartiCard.listItem(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: n['title'] as String? ?? '',
                        subtitle: n['body'] as String?,
                        onTap: () => _showNotificationDetail(n),
                      );
                    },
                  ),
                ),
    );
  }

  void _showNotificationDetail(Map<String, dynamic> n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              n['title'] as String? ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            Text(
              n['body'] as String? ?? '',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
