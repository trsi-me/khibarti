import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/join_session_screen.dart';
import 'package:khibarti/screens/notifications_screen.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';
import 'package:khibarti/utils/session_format.dart';
import 'package:khibarti/screens/expert_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService.instance;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _experts = [];
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;
    final q = _searchController.text.trim();
    final experts = await _api.getExperts(
      search: q.isEmpty ? null : q,
    );
    final sessions = await _api.getSessionsForUser(userId, status: 'upcoming');
    final notifications = await _api.getNotificationsForUser(userId);
    if (mounted) {
      setState(() {
        _experts = experts;
        _sessions = sessions;
        _notifications = notifications;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userName = AppState.currentUser?['name'] as String? ?? l10n.welcome;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.welcome}، $userName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildSectionTitle(l10n.suggestedExperts),
            const SizedBox(height: 8),
            _buildSuggestedExperts(),
            const SizedBox(height: 16),
            _buildSectionTitle(l10n.upcomingSessions),
            const SizedBox(height: 8),
            _buildUpcomingSessions(context),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _openNotifications,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(l10n.notifications),
                    Text(l10n.viewAll, style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildNotifications(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadData(),
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildSuggestedExperts() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _experts.length,
        itemBuilder: (context, i) {
          final e = _experts[i];
          final expertId = e['id'] as int?;
          return _ExpertCard(
            name: e['name'] as String? ?? '',
            specialty: e['specialty'] as String? ?? '',
            rating: ((e['rating'] ?? 0) as num).toDouble(),
            isVerified: (e['is_verified'] == 1 || e['is_verified'] == true),
            onTap: expertId == null
                ? () {}
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpertDetailScreen(expertId: expertId),
                      ),
                    ).then((_) => _loadData());
                  },
          );
        },
      ),
    );
  }

  Widget _buildUpcomingSessions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_sessions.isEmpty) {
      return KhibartiCard.empty(message: l10n.noSessions, icon: Icons.event_available_rounded);
    }
    return Column(
      children: _sessions.map((s) {
        return KhibartiCard.listItem(
          leading: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF1B5E57),
            child: Icon(Icons.event_available_rounded, color: AppColors.onPrimary, size: 22),
          ),
          title: s['expert_name'] as String? ?? '',
          subtitle: [
            formatSessionWhen(
              s['scheduled_date'] as String? ?? '',
              s['scheduled_time'] as String? ?? '',
              AppState.locale,
            ),
            s['specialty'] as String? ?? '',
          ].where((e) => e.trim().isNotEmpty).join('\n'),
          actions: [
            ElevatedButton(
              onPressed: () => _openJoinSession(s),
              child: Text(l10n.join),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _openJoinSession(Map<String, dynamic> session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JoinSessionScreen(
          sessionId: session['id'] as int?,
          expertName: session['expert_name'] as String? ?? '',
          date: session['scheduled_date'] as String? ?? '',
          time: session['scheduled_time'] as String? ?? '',
          specialty: session['specialty'] as String? ?? 'تخصص',
        ),
      ),
    ).then((_) => _loadData());
  }

  void _openNotifications() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())).then((_) => _loadData());
  }

  Widget _buildNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_notifications.isEmpty) {
      return KhibartiCard.empty(message: l10n.noNotifications, icon: Icons.notifications_none_rounded);
    }
    return Column(
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
          onTap: _openNotifications,
        );
      }).toList(),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final bool isVerified;
  final VoidCallback onTap;

  const _ExpertCard({
    required this.name,
    required this.specialty,
    required this.rating,
    this.isVerified = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: KhibartiCard.expert(
        name: name,
        specialty: specialty,
        rating: rating,
        isVerified: isVerified,
        onTap: onTap,
        width: 168,
      ),
    );
  }
}
