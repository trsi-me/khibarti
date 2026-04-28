import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/services/certificate_service.dart';
import 'package:khibarti/utils/session_format.dart';

/// شاشة الجلسة — محادثة فقط (بدون مكالمة فيديو)
class JoinSessionScreen extends StatefulWidget {
  final int? sessionId;
  final String expertName;
  final String date;
  final String time;
  final String specialty;

  const JoinSessionScreen({
    super.key,
    this.sessionId,
    required this.expertName,
    required this.date,
    required this.time,
    this.specialty = 'تخصص',
  });

  @override
  State<JoinSessionScreen> createState() => _JoinSessionScreenState();
}

class _JoinSessionScreenState extends State<JoinSessionScreen> {
  final List<Map<String, String>> _userMessages = [];
  final _controller = TextEditingController();
  final _api = ApiService.instance;

  @override
  void initState() {
    super.initState();
    _recordAttendance();
  }

  Future<void> _recordAttendance() async {
    if (widget.sessionId == null) return;
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;
    await _api.recordAttendance(widget.sessionId!, userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getMessages(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'sender': 'system', 'text': l10n.welcomeToSession},
      {'sender': 'expert', 'text': l10n.expertGreeting},
      {'sender': 'you', 'text': l10n.readyToStart},
      ..._userMessages,
    ];
  }

  Future<void> _endSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).endSession),
        content: const Text('هل تريد إنهاء الجلسة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('نعم')),
        ],
      ),
    );
    if (confirm != true) return;
    if (widget.sessionId != null) {
      await _api.completeSession(widget.sessionId!);
      final userId = AppState.currentUser?['id'] as int?;
      if (userId != null) {
        await _api.createCertificate(
          sessionId: widget.sessionId!,
          userId: userId,
          expertName: widget.expertName,
          specialty: widget.specialty,
          sessionDate: '${widget.date} ${widget.time}',
        );
        await CertificateService.generateAndSave(
          expertName: widget.expertName,
          specialty: widget.specialty,
          sessionDate: '${widget.date} ${widget.time}',
          userName: AppState.currentUser?['name'] as String? ?? 'المستخدم',
        );
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionWith(widget.expertName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.endSession,
            onPressed: _endSession,
          ),
        ],
      ),
      body: _buildChatArea(context),
    );
  }

  Widget _buildChatArea(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.expertName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E57)),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  formatSessionWhen(widget.date, widget.time, AppState.locale),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✓ تم تسجيل حضورك',
                    style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chat,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _getMessages(context).length,
              itemBuilder: (context, i) {
                final m = _getMessages(context)[i];
                final isYou = m['sender'] == 'you';
                return Align(
                  alignment: isYou ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isYou ? const Color(0xFF1B5E57).withOpacity(0.2) : const Color(0xFFF8FAF9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(fontSize: 14, color: isYou ? const Color(0xFF1B5E57) : Colors.grey.shade800),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.typeMessage,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _userMessages.add({'sender': 'you', 'text': text}));
    _controller.clear();
  }
}
