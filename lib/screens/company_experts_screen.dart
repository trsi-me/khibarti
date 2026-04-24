import 'package:flutter/material.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/widgets/khibarti_card.dart';
import 'package:khibarti/screens/expert_chat_screen.dart';

/// واجهة الشركة — استعراض الخبراء والتواصل معهم
class CompanyExpertsScreen extends StatefulWidget {
  const CompanyExpertsScreen({super.key});

  @override
  State<CompanyExpertsScreen> createState() => _CompanyExpertsScreenState();
}

class _CompanyExpertsScreenState extends State<CompanyExpertsScreen> {
  final _api = ApiService.instance;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _experts = [];
  List<String> _specialties = [];
  String _selectedSpecialty = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
    _loadExperts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    final s = await _api.getSpecialties();
    setState(() {
      _specialties = ['الكل', ...s];
      if (!_specialties.contains(_selectedSpecialty)) _selectedSpecialty = 'الكل';
    });
  }

  Future<void> _loadExperts() async {
    final experts = await _api.getExperts(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      specialty: _selectedSpecialty == 'الكل' ? null : _selectedSpecialty,
    );
    setState(() => _experts = experts);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPartners)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.browseExperts,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadExperts(),
              decoration: InputDecoration(
                hintText: l10n.searchExpertHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _loadExperts,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _specialties.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(s),
                      selected: _selectedSpecialty == s,
                      onSelected: (_) {
                        setState(() {
                          _selectedSpecialty = s;
                          _loadExperts();
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: const Color(0xFF1B5E57).withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _experts.length,
              itemBuilder: (context, i) {
                final e = _experts[i];
                final expertUserId = e['user_id'] as int?;
                final expertName = e['name'] as String? ?? '';
                return KhibartiCard.expert(
                  name: expertName,
                  specialty: e['specialty'] as String? ?? '',
                  rating: ((e['rating'] ?? 0) as num).toDouble(),
                  extraInfo: '${e['sessions_count'] ?? 0} جلسة',
                  onTap: expertUserId != null
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExpertChatScreen(expertUserId: expertUserId, expertName: expertName),
                            ),
                          )
                      : () {},
                  action: expertUserId != null
                      ? SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpertChatScreen(expertUserId: expertUserId, expertName: expertName),
                              ),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: Text(l10n.contact),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
