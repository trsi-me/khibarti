import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/join_session_screen.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';
import 'package:khibarti/utils/session_format.dart';
import 'package:khibarti/utils/accessibility_dim.dart';

/// جلسات الخبير فقط — انضم، إلغاء. لا تقييم ولا شهادة (الطالب من يقيّم)
class ExpertSessionsScreen extends StatefulWidget {
  const ExpertSessionsScreen({super.key});

  @override
  State<ExpertSessionsScreen> createState() => _ExpertSessionsScreenState();
}

class _ExpertSessionsScreenState extends State<ExpertSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _api = ApiService.instance;
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _completed = [];
  List<Map<String, dynamic>> _cancelled = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;
    final upcoming = await _api.getSessionsForUser(userId, status: 'upcoming');
    final completed = await _api.getSessionsForUser(userId, status: 'completed');
    final cancelled = await _api.getSessionsForUser(userId, status: 'cancelled');
    if (mounted) {
      setState(() {
        _upcoming = upcoming;
        _completed = completed;
        _cancelled = cancelled;
      });
    }
  }

  Future<void> _cancelSession(Map<String, dynamic> session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الجلسة'),
        content: const Text('هل أنت متأكد من إلغاء هذه الجلسة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('نعم')),
        ],
      ),
    );
    if (confirm == true) {
      await _api.cancelSession(session['id'] as int);
      _loadData();
    }
  }

  void _openJoinSession(Map<String, dynamic> session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JoinSessionScreen(
          sessionId: session['id'] as int,
          expertName: session['expert_name'] as String,
          date: session['scheduled_date'] as String,
          time: session['scheduled_time'] as String,
          specialty: session['specialty'] as String? ?? 'تخصص',
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navExpertSessions),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.tabUpcoming),
            Tab(text: l10n.tabCompleted),
            Tab(text: l10n.tabCancelled),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SessionList(
            sessions: _upcoming,
            isUpcoming: true,
            isExpert: true,
            onJoin: _openJoinSession,
            onCancel: _cancelSession,
          ),
          _SessionList(
            sessions: _completed,
            isUpcoming: false,
            isExpert: true,
            onJoin: _openJoinSession,
            onCancel: _cancelSession,
          ),
          _SessionList(
            sessions: _cancelled,
            isUpcoming: false,
            isCancelled: true,
            isExpert: true,
            onJoin: _openJoinSession,
            onCancel: _cancelSession,
          ),
        ],
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final bool isUpcoming;
  final bool isCancelled;
  final bool isExpert;
  final void Function(Map<String, dynamic>) onJoin;
  final void Function(Map<String, dynamic>) onCancel;

  const _SessionList({
    required this.sessions,
    required this.isUpcoming,
    this.isCancelled = false,
    this.isExpert = false,
    required this.onJoin,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? l10n.noUpcoming : (isCancelled ? 'لا توجد جلسات ملغاة' : l10n.noCompleted),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, i) {
        final s = sessions[i];
        final when = formatSessionWhen(
          s['scheduled_date'] as String? ?? '',
          s['scheduled_time'] as String? ?? '',
          Localizations.localeOf(context),
        );
        final spec = s['specialty'] as String? ?? '';
        final title = l10n.withStudent;
        final subtitle = [when, spec].where((e) => e.isNotEmpty).join('\n');
        List<Widget>? actions;
        if (isUpcoming && !isCancelled) {
          actions = [
            Expanded(child: ElevatedButton(onPressed: () => onJoin(s), child: Text(l10n.join))),
            Expanded(child: OutlinedButton(
              onPressed: () => onCancel(s),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD32F2F), side: const BorderSide(color: Color(0xFFD32F2F))),
              child: Text(l10n.cancel),
            )),
          ];
        }
        return KhibartiCard.listItem(
          leading: CircleAvatar(
            radius: 24.aks,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              (s['expert_name'] as String? ?? '?').isNotEmpty ? (s['expert_name'] as String)[0] : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          title: title,
          subtitle: subtitle,
          actions: actions,
        );
      },
    );
  }
}
