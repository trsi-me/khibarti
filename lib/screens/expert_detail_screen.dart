import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/expert_chat_screen.dart';

class ExpertDetailScreen extends StatefulWidget {
  final int expertId;

  const ExpertDetailScreen({super.key, required this.expertId});

  @override
  State<ExpertDetailScreen> createState() => _ExpertDetailScreenState();
}

class _ExpertDetailScreenState extends State<ExpertDetailScreen> {
  final _api = ApiService.instance;
  Map<String, dynamic>? _expert;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await _api.getExpertById(widget.expertId);
    if (mounted) setState(() => _expert = e);
  }

  Future<void> _bookSession() async {
    final user = AppState.currentUser;
    if (user == null) return;
    final studentId = await _api.getStudentIdByUserId(user['id'] as int);
    if (studentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يجب أن تكون طالباً لحجز جلسة')));
      return;
    }
    final now = DateTime.now();
    final date =
        '${now.year}-${(now.month).toString().padLeft(2, '0')}-${(now.day + 3).toString().padLeft(2, '0')}';
    final time = '10:00';
    await _api.bookSession(widget.expertId, studentId, date, time);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم حجز الجلسة بنجاح')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_expert == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.exploreTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final name = _expert!['name'] as String? ?? '';
    final specialty = _expert!['specialty'] as String? ?? '';
    final rating = ((_expert!['rating'] ?? 0) as num).toDouble();
    final years = _expert!['years_experience'] as int? ?? 0;
    final sessionsCount = _expert!['sessions_count'] as int? ?? 0;
    final bio = _expert!['bio'] as String? ?? '';
    final verified = _expert!['is_verified'] == 1 || _expert!['is_verified'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1B5E57).withOpacity(0.3),
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: Color(0xFF1B5E57),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (verified) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.expertVerifiedBadge,
                    child: Icon(Icons.verified_rounded, color: Colors.teal.shade700, size: 28),
                  ),
                ],
              ],
            ),
            Text(
              specialty,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 6),
                Text(
                  '$rating',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.work_outline, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$years ${'سنوات خبرة'}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 20),
                Text(
                  '$sessionsCount جلسة',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نبذة شخصية',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bio,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final expertUserId = _expert!['user_id'] as int?;
                      if (expertUserId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpertChatScreen(
                              expertUserId: expertUserId,
                              expertName: name,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.contactExpert),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _bookSession,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(l10n.bookSession),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
