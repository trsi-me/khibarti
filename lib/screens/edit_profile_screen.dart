import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/services/api_service.dart' show ApiService, ApiException;
import 'package:khibarti/services/session_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _api = ApiService.instance;
  final _picker = ImagePicker();
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    final user = AppState.currentUser;
    if (user != null) {
      _nameController.text = user['name'] as String? ?? '';
      _emailController.text = user['email'] as String? ?? '';
      _phoneController.text = user['phone'] as String? ?? '+966 500 000 000';
      _countryController.text = user['country'] as String? ?? 'المملكة العربية السعودية';
      _avatarBase64 = user['avatar'] as String?;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted && !status.isLimited) {
      status = await Permission.storage.request();
    }
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب منح صلاحية الوصول للصور لرفع الصورة'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      if (img != null && mounted) {
        final bytes = await img.readAsBytes();
        setState(() => _avatarBase64 = base64Encode(bytes));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل اختيار الصورة، تأكد من منح الصلاحية'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = AppState.currentUser?['id'] as int?;
    if (userId == null) return;

    try {
      final updated = await _api.updateUser(
        userId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        avatar: _avatarBase64,
      );

      if (updated != null) {
        AppState.currentUser = updated;
        await SessionService.saveUser(updated);
      } else {
        AppState.currentUser ??= {};
        AppState.currentUser!['name'] = _nameController.text.trim();
        AppState.currentUser!['phone'] = _phoneController.text.trim();
        AppState.currentUser!['country'] = _countryController.text.trim();
        AppState.currentUser!['avatar'] = _avatarBase64;
        await SessionService.saveUser(AppState.currentUser!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: _pickAvatar,
                borderRadius: BorderRadius.circular(60),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  backgroundImage: _avatarBase64 != null
                      ? MemoryImage(base64Decode(_avatarBase64!))
                      : null,
                  child: _avatarBase64 == null
                      ? Text(
                          _nameController.text.trim().isNotEmpty ? _nameController.text.trim()[0] : '?',
                          style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.profilePhoto, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(l10n.tapToUploadPhoto, style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 11)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                textDirection: TextDirection.rtl,
                validator: (v) => v == null || v.trim().isEmpty ? 'أدخل الاسم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  helperText: 'البريد لا يُعدّل (للتسجيل)',
                ),
                readOnly: true,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  hintText: '+966 5XX XXX XXXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: l10n.country,
                  hintText: l10n.saudiArabia,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
