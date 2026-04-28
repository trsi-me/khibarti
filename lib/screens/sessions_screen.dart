import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/join_session_screen.dart';
import 'package:khibarti/services/certificate_service.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';
import 'package:khibarti/utils/session_format.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
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

  void _showRateDialog(Map<String, dynamic> session) async {
    int selectedScore = 0;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('تقييم الجلسة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كم نجمة تعطي من 5؟'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final s = i + 1;
                  return IconButton(
                    icon: Icon(selectedScore >= s ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                    onPressed: () => setDialogState(() => selectedScore = s),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: selectedScore > 0
                  ? () async {
                      Navigator.pop(ctx);
                      final userId = AppState.currentUser?['id'] as int?;
                      if (userId == null) return;
                      final expertUserId = await _api.getExpertUserIdByExpertId(session['expert_id'] as int);
                      if (expertUserId != null) {
                        await _api.addRating(session['id'] as int, userId, expertUserId, selectedScore);
                        _loadData();
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التقييم')));
                      }
                    }
                  : null,
              child: const Text('تقييم'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadCertificate(Map<String, dynamic> session) async {
    final expertName = session['expert_name'] as String? ?? '';
    final specialty = session['specialty'] as String? ?? '';
    final sessionDate = '${session['scheduled_date']} ${session['scheduled_time']}';
    final userName = AppState.currentUser?['name'] as String? ?? 'المستخدم';

    await _api.createCertificate(
      sessionId: session['id'] as int,
      userId: AppState.currentUser?['id'] as int,
      expertName: expertName,
      specialty: specialty,
      sessionDate: sessionDate,
    );
    final path = await CertificateService.generateAndSave(
      expertName: expertName,
      specialty: specialty,
      sessionDate: sessionDate,
      userName: userName,
    );
    if (mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ الشهادة: $path')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل في إنشاء الشهادة')));
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
        title: Text(l10n.navSessions),
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
            onJoin: _openJoinSession,
            onCancel: _cancelSession,
          ),
          _SessionList(
            sessions: _completed,
            isUpcoming: false,
            onJoin: _openJoinSession,
            onCancel: _cancelSession,
            onRate: _showRateDialog,
            onDownloadCertificate: _downloadCertificate,
          ),
          _SessionList(
            sessions: _cancelled,
            isUpcoming: false,
            isCancelled: true,
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
  final void Function(Map<String, dynamic>) onJoin;
  final void Function(Map<String, dynamic>) onCancel;
  final void Function(Map<String, dynamic>)? onRate;
  final void Function(Map<String, dynamic>)? onDownloadCertificate;

  const _SessionList({
    required this.sessions,
    required this.isUpcoming,
    this.isCancelled = false,
    required this.onJoin,
    required this.onCancel,
    this.onRate,
    this.onDownloadCertificate,
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
        final expertName = s['expert_name'] as String? ?? '';
        final dateTime = [
          formatSessionWhen(
            s['scheduled_date'] as String? ?? '',
            s['scheduled_time'] as String? ?? '',
            AppState.locale,
          ),
          s['specialty'] as String? ?? '',
        ].where((e) => e.trim().isNotEmpty).join('\n');
        List<Widget> actions = [];
        if (isUpcoming && !isCancelled) {
          actions = [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onJoin(s),
                child: Text(l10n.join),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => onCancel(s),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: Text(l10n.cancel),
              ),
            ),
          ];
        } else if (!isUpcoming && !isCancelled && (onRate != null || onDownloadCertificate != null)) {
          actions = [
            if (onRate != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onRate!(s),
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(l10n.rateSession),
                ),
              ),
            if (onDownloadCertificate != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onDownloadCertificate!(s),
                  icon: const Icon(Icons.download, size: 18),
                  label: Text(l10n.downloadCertificate),
                ),
              ),
          ];
        }
        return KhibartiCard.listItem(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              expertName.isNotEmpty ? expertName[0] : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          title: expertName,
          subtitle: dateTime,
          actions: actions.isEmpty ? null : actions,
        );
      },
    );
  }
}
