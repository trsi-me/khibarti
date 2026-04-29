import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/theme/app_theme.dart';

/// لوحة «مسؤول الشراكات» + إدارة حسابات الشركة الفرعية (مفوّضون)
class CompanyOfficerHubScreen extends StatefulWidget {
  const CompanyOfficerHubScreen({super.key});

  @override
  State<CompanyOfficerHubScreen> createState() => _CompanyOfficerHubScreenState();
}

class _CompanyOfficerHubScreenState extends State<CompanyOfficerHubScreen> {
  final _api = ApiService.instance;
  List<Map<String, dynamic>> _delegates = [];
  List<Map<String, dynamic>> _partnerRequests = [];
  bool _loading = false;
  bool _loadingPartnerRequests = false;

  bool get _canManageTeam {
    final r = AppState.currentUser?['role_name'] as String? ?? '';
    return r == 'company' || r == 'company_manager';
  }

  bool get _isCompanyOfficer {
    final r = AppState.currentUser?['role_name'] as String? ?? '';
    return r == 'company' || r == 'company_manager' || r == 'company_delegate';
  }

  int? get _ownerUserId => AppState.currentUser?['id'] as int?;

  @override
  void initState() {
    super.initState();
    if (_isCompanyOfficer) _loadPartnerRequests();
    if (_canManageTeam) _loadDelegates();
  }

  Future<void> _loadPartnerRequests() async {
    final id = _ownerUserId;
    if (id == null) return;
    setState(() => _loadingPartnerRequests = true);
    final list = await _api.getCompanyPartnerRequests(id, status: 'pending');
    if (mounted) {
      setState(() {
        _partnerRequests = list;
        _loadingPartnerRequests = false;
      });
    }
  }

  Future<void> _decidePartnerRequest(AppLocalizations l10n, int requestId, bool approve) async {
    final id = _ownerUserId;
    if (id == null) return;
    final err = await _api.decideCompanyPartnerRequest(
      officerUserId: id,
      requestId: requestId,
      approve: approve,
    );
    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.partnerRequestProcessed)));
      _loadPartnerRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _loadDelegates() async {
    final id = _ownerUserId;
    if (id == null) return;
    setState(() => _loading = true);
    final list = await _api.getCompanyDelegates(id);
    if (mounted) {
      setState(() {
        _delegates = list;
        _loading = false;
      });
    }
  }

  Future<void> _openAddDelegateDialog(AppLocalizations l10n) async {
    final id = _ownerUserId;
    if (id == null) return;
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.companyTeamDialogTitle, textDirection: TextDirection.rtl),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l10n.name),
                textDirection: TextDirection.rtl,
              ),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
              ),
              TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.createAccount),
          ),
        ],
      ),
    );
    if (ok != true) {
      emailCtrl.dispose();
      passCtrl.dispose();
      nameCtrl.dispose();
      return;
    }
    final email = emailCtrl.text.trim();
    final password = passCtrl.text;
    final name = nameCtrl.text.trim();
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    if (!mounted) return;
    if (email.isEmpty || name.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.companyTeamValidationError)),
      );
      return;
    }
    final created = await _api.createCompanyDelegate(
      ownerUserId: id,
      email: email,
      password: password,
      name: name,
    );
    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.companyTeamAdded)));
      _loadDelegates();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  Future<void> _confirmDelete(AppLocalizations l10n, int delegateId) async {
    final id = _ownerUserId;
    if (id == null) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.companyTeamDeleteTitle, textDirection: TextDirection.rtl),
        content: Text(l10n.companyTeamDeleteBody, textDirection: TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final err = await _api.deleteCompanyDelegate(ownerUserId: id, delegateId: delegateId);
    if (!mounted) return;
    if (err == null) {
      _loadDelegates();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.companyOfficerHubTitle)),
      floatingActionButton: _canManageTeam
          ? FloatingActionButton.extended(
              onPressed: () => _openAddDelegateDialog(l10n),
              icon: const Icon(Icons.person_add_outlined),
              label: Text(l10n.companyTeamAdd),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.companyOfficerHubSubtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          if (_isCompanyOfficer) ...[
            Text(
              l10n.partnerRequestsSectionTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.partnerRequestsSectionHint,
              style: TextStyle(fontSize: 14, height: 1.35, color: AppColors.textSecondary),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 14),
            if (_loadingPartnerRequests)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_partnerRequests.isEmpty)
              Text(
                l10n.partnerRequestsEmpty,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                textDirection: TextDirection.rtl,
              )
            else
              Column(
                children: _partnerRequests.map((row) {
                  final rid = row['id'] as int?;
                  final name = row['expert_name']?.toString() ?? '';
                  final spec = row['specialty']?.toString() ?? '';
                  if (rid == null) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(name, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          if (spec.isNotEmpty)
                            Text(spec, textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 10),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => _decidePartnerRequest(l10n, rid, true),
                                  child: Text(l10n.partnerRequestApprove),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _decidePartnerRequest(l10n, rid, false),
                                  child: Text(l10n.partnerRequestReject),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
          ],
          _bullet(context, Icons.groups_outlined, l10n.companyOfficerBullet1),
          const SizedBox(height: 12),
          _bullet(context, Icons.notifications_active_outlined, l10n.companyOfficerBullet2),
          const SizedBox(height: 12),
          _bullet(context, Icons.handshake_outlined, l10n.companyOfficerBullet3),
          const SizedBox(height: 28),
          Text(
            l10n.companyTeamSectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            _canManageTeam ? l10n.companyTeamSectionSubtitle : l10n.companyTeamReadOnlyHint,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          if (_canManageTeam)
            _loading
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                : _delegates.isEmpty
                    ? Text(
                        l10n.companyTeamEmpty,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                        textDirection: TextDirection.rtl,
                      )
                    : Column(
                        children: _delegates.map((d) {
                          final did = d['id'] as int?;
                          final name = d['name']?.toString() ?? '';
                          final email = d['email']?.toString() ?? '';
                          if (did == null) return const SizedBox.shrink();
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(name, textDirection: TextDirection.rtl),
                              subtitle: Text(email, textDirection: TextDirection.ltr),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(l10n, did),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
        ],
      ),
    );
  }

  Widget _bullet(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
