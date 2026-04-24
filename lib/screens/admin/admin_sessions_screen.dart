import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/theme/app_theme.dart';

/// جميع جلسات المنصة — عرض وتحديث الحالة
class AdminSessionsScreen extends StatefulWidget {
  const AdminSessionsScreen({super.key});

  @override
  State<AdminSessionsScreen> createState() => _AdminSessionsScreenState();
}

class _AdminSessionsScreenState extends State<AdminSessionsScreen> {
  final _api = ApiService.instance;
  List<Map<String, dynamic>> _sessions = [];
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
    final list = await _api.getAdminSessions(id);
    if (mounted) {
      setState(() {
        _sessions = list;
        _loading = false;
      });
    }
  }

  String _statusLabel(AppLocalizations l10n, String status) {
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

  Color _statusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppColors.darkBlue;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _changeStatus(int sessionId, String newStatus) async {
    await _api.updateSessionStatus(sessionId, newStatus);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحديث حالة الجلسة'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminSessionsTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _sessions.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Center(child: Text(l10n.adminServerError)),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _sessions.length,
                    itemBuilder: (context, i) {
                      final s = _sessions[i];
                      final id = s['id'];
                      final sid = id is int ? id : int.tryParse(id.toString()) ?? 0;
                      final status = s['status']?.toString() ?? '';
                      final expert = s['expert_name']?.toString() ?? '';
                      final student = s['student_name']?.toString() ?? '';
                      final date = s['scheduled_date']?.toString() ?? '';
                      final time = s['scheduled_time']?.toString() ?? '';
                      final spec = s['specialty']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$date — $time',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: _statusColor(status)),
                                    onSelected: (v) => _changeStatus(sid, v),
                                    itemBuilder: (ctx) => [
                                      PopupMenuItem(value: 'upcoming', child: Text(l10n.tabUpcoming)),
                                      PopupMenuItem(value: 'completed', child: Text(l10n.tabCompleted)),
                                      PopupMenuItem(value: 'cancelled', child: Text(l10n.tabCancelled)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${l10n.expert}: $expert',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${l10n.student}: $student',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (spec.isNotEmpty)
                                Text(
                                  '${l10n.filterSpecialty}: $spec',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Chip(
                                  label: Text(_statusLabel(l10n, status)),
                                  backgroundColor: _statusColor(status).withOpacity(0.15),
                                  side: BorderSide(color: _statusColor(status).withOpacity(0.4)),
                                ),
                              ),
                              Text(
                                '${l10n.navSessions} #$sid',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
