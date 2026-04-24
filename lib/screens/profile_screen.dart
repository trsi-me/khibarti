import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart' show ApiService, ApiException;
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/edit_profile_screen.dart';
import 'package:khibarti/widgets/khibarti_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService.instance;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _user = AppState.currentUser;
  }

  void _openEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    ).then((_) => setState(() => _user = AppState.currentUser));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = _user?['name'] as String? ?? l10n.demoUser;
    final email = _user?['email'] as String? ?? 'user@example.com';
    final phone = _user?['phone'] as String? ?? '+966 500 000 000';
    final country = _user?['country'] as String? ?? l10n.saudiArabia;
    final roleName = _user?['role_name'] as String? ?? '';
    final avatarBase64 = _user?['avatar'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _openEditProfile,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF1B5E57).withOpacity(0.3),
                    backgroundImage: avatarBase64 != null ? MemoryImage(base64Decode(avatarBase64)) : null,
                    child: avatarBase64 == null ? Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(fontSize: 36, color: Color(0xFF1B5E57), fontWeight: FontWeight.bold),
                    ) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E57),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            if (roleName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Chip(
                  label: Text(_displayRole(l10n, roleName)),
                  backgroundColor: const Color(0xFF1B5E57).withOpacity(0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 32),
            KhibartiCard.profileField(label: l10n.name, value: name, onTap: _openEditProfile),
            KhibartiCard.profileField(label: l10n.email, value: email, onTap: _openEditProfile),
            KhibartiCard.profileField(label: l10n.phone, value: phone, onTap: _openEditProfile),
            KhibartiCard.profileField(label: l10n.country, value: country, onTap: _openEditProfile),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit),
                label: Text(l10n.editProfile),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock),
                label: Text(l10n.changePassword),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E57),
                  side: const BorderSide(color: Color(0xFF1B5E57)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
            onPressed: () async {
              if (newController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور 6 أحرف على الأقل')));
                return;
              }
              final userId = AppState.currentUser?['id'] as int?;
              if (userId != null) {
                try {
                  await _api.updateUser(userId, password: newController.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور')));
                } on ApiException catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
                  );
                }
              }
            },
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  String _displayRole(AppLocalizations l10n, String role) {
    switch (role) {
      case 'student':
        return l10n.student;
      case 'expert':
        return l10n.expert;
      case 'company':
        return l10n.company;
      case 'admin':
        return l10n.roleAdmin;
      default:
        return role;
    }
  }
}

