import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/services/session_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/join_session_screen.dart';
import 'package:khibarti/screens/expert_chat_screen.dart';
import 'package:khibarti/screens/notifications_screen.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/utils/accessibility_dim.dart';
import 'package:khibarti/widgets/khibarti_card.dart';
import 'package:khibarti/utils/session_format.dart';

/// واجهة الخبير فقط — جلساتي القادمة، إحصائياتي، إشعارات
class ExpertHomeScreen extends StatefulWidget {
  const ExpertHomeScreen({super.key});

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> with WidgetsBindingObserver {
  final _api = ApiService.instance;
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _expertProfile;
  Map<String, dynamic>? _partnerDirStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadData();
  }

  Future<void> _loadData() async {
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;
    final sessions = await _api.getSessionsForUser(userId, status: 'upcoming');
    final notifications = await _api.getNotificationsForUser(userId);
    final conversations = await _api.getConversations(userId);
    final myExpert = await _api.getExpertByUserId(userId);
    final partnerDir = await _api.getExpertPartnerDirectoryStatus(userId);
    if (myExpert != null && AppState.currentUser != null) {
      final ev = myExpert['is_verified'] == 1 || myExpert['is_verified'] == true;
      AppState.currentUser!['expert_verified'] = ev ? 1 : 0;
      await SessionService.saveUser(AppState.currentUser!);
    }
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _notifications = notifications;
        _conversations = conversations;
        _expertProfile = myExpert;
        _partnerDirStatus = partnerDir;
      });
    }
  }

  Future<void> _submitPartnerDirectoryRequest(AppLocalizations l10n) async {
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;
    final err = await _api.submitExpertPartnerDirectoryRequest(userId);
    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.expertPartnerDirRequestSent)));
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userName = AppState.currentUser?['name'] as String? ?? '';
    final rating = ((_expertProfile?['rating'] ?? 0) as num).toDouble();
    final sessionsCount = _expertProfile?['sessions_count'] as int? ?? 0;
    final verified = _expertProfile?['is_verified'] == 1 || _expertProfile?['is_verified'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.expertDashboard)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.welcome}، $userName',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (verified)
                  Tooltip(
                    message: l10n.expertVerifiedBadge,
                    child: Icon(Icons.verified_rounded, color: Colors.teal.shade700, size: 28.aks),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStats(context, rating, sessionsCount),
            const SizedBox(height: 16),
            _buildPartnerDirectoryCard(context, l10n),
            const SizedBox(height: 20),
            _buildSectionTitle(l10n.mySessionsAsExpert),
            const SizedBox(height: 8),
            _buildSessions(context),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            _buildSectionTitle(l10n.myConversations),
            const SizedBox(height: 8),
            _buildConversations(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerDirectoryCard(BuildContext context, AppLocalizations l10n) {
    final s = _partnerDirStatus;
    if (s == null) return const SizedBox.shrink();
    final inDir = s['inDirectory'] == true || s['inDirectory'] == 1;
    final rs = s['requestStatus'] as String?;
    return Card(
      elevation: 0,
      color: AppColors.primary.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.expertPartnerDirCardTitle,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            if (inDir)
              Text(
                l10n.expertPartnerDirListed,
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.w600),
              )
            else if (rs == 'pending')
              Text(
                l10n.expertPartnerDirPending,
                textDirection: TextDirection.rtl,
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              )
            else if (rs == 'rejected') ...[
              Text(
                l10n.expertPartnerDirRejected,
                textDirection: TextDirection.rtl,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _submitPartnerDirectoryRequest(l10n),
                icon: Icon(Icons.refresh_rounded, size: 20.aks),
                label: Text(l10n.expertPartnerDirRequestCta),
              ),
            ] else ...[
              Text(
                l10n.expertPartnerDirIntro,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => _submitPartnerDirectoryRequest(l10n),
                icon: Icon(Icons.handshake_outlined, size: 20.aks),
                label: Text(l10n.expertPartnerDirRequestCta),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, double rating, int sessionsCount) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: KhibartiCard.stat(
            icon: Icons.star_rounded,
            value: rating.toStringAsFixed(1),
            label: l10n.myRating,
            iconColor: Colors.amber,
            showValue: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KhibartiCard.stat(
            icon: Icons.event_available_rounded,
            value: '$sessionsCount',
            label: l10n.totalSessions,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildSessions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_sessions.isEmpty) {
      return KhibartiCard.empty(message: l10n.noExpertSessions, icon: Icons.event_available_rounded);
    }
    return Column(
      children: _sessions.map((s) {
        return KhibartiCard.listItem(
          leading: CircleAvatar(
            radius: 24.aks,
            backgroundColor: Color(0xFF1B5E57),
            child: Icon(Icons.event_available_rounded, color: AppColors.onPrimary, size: 22.aks),
          ),
          title: l10n.withStudent,
          subtitle: [
            formatSessionWhen(
              s['scheduled_date'] as String? ?? '',
              s['scheduled_time'] as String? ?? '',
              AppState.locale,
            ),
            s['specialty'] as String? ?? '',
          ].where((e) => e.isNotEmpty).join('\n'),
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
            child: Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22.aks),
          ),
          title: n['title'] as String? ?? '',
          subtitle: n['body'] as String?,
          onTap: _openNotifications,
        );
      }).toList(),
    );
  }

  Widget _buildConversations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_conversations.isEmpty) {
      return KhibartiCard.empty(message: l10n.noConversations, icon: Icons.chat_bubble_outline);
    }
    return Column(
      children: _conversations.map((c) {
        final otherId = c['other_user_id'] as int?;
        final otherName = c['other_user_name'] as String? ?? '?';
        if (otherId == null) return const SizedBox.shrink();
        return KhibartiCard.listItem(
          leading: CircleAvatar(
            radius: 24.aks,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              otherName.isNotEmpty ? otherName[0] : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          title: otherName,
          subtitle: l10n.tapToReply,
          actions: [
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpertChatScreen(expertUserId: otherId, expertName: otherName),
                ),
              ).then((_) => _loadData()),
              icon: Icon(Icons.chat_bubble_outline, size: 18.aks),
              label: Text(l10n.contact),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
