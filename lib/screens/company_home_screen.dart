import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';
import 'package:khibarti/screens/notifications_screen.dart';

/// واجهة الشركة فقط — نظرة عامة، إحصائيات المنصة
class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  final _api = ApiService.instance;
  List<Map<String, dynamic>> _experts = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;
    final experts = await _api.getExperts();
    final notifications = await _api.getNotificationsForUser(userId);
    if (mounted) {
      setState(() {
        _experts = experts;
        _notifications = notifications;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userName = AppState.currentUser?['name'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.companyDashboard)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.welcome}، $userName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildStats(context),
            const SizedBox(height: 20),
            _buildSectionTitle(l10n.platformOverview),
            const SizedBox(height: 8),
            Text(
              l10n.viewOnly,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 20),
            _buildNotificationsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KhibartiCard.stat(
      icon: Icons.people_outline,
      value: '${_experts.length}',
      label: l10n.expertsCount,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  void _openNotificationsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    ).then((_) => _loadData());
  }

  Widget _buildNotificationsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _openNotificationsScreen,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(l10n.notifications),
                Text(
                  l10n.viewAll,
                  style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_notifications.isEmpty)
          KhibartiCard.empty(message: l10n.noNotifications, icon: Icons.notifications_none_rounded)
        else
          Column(
            children: _notifications.take(3).map((n) {
              return KhibartiCard.listItem(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
                ),
                title: n['title'] as String? ?? '',
                subtitle: n['body'] as String?,
                onTap: _openNotificationsScreen,
              );
            }).toList(),
          ),
      ],
    );
  }
}
