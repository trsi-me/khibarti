import 'package:flutter/material.dart';
import 'package:khibarti/services/api_service.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/expert_detail_screen.dart';
import 'package:khibarti/widgets/khibarti_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _api = ApiService.instance;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _experts = [];
  List<String> _specialties = [];
  String _selectedSpecialty = 'الكل';
  int _minYears = 0;

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
      minYears: _minYears > 0 ? _minYears : null,
    );
    setState(() => _experts = experts);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navExplore)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildFilters(context),
            const SizedBox(height: 24),
            _buildExpertGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _searchController,
      onSubmitted: (_) => _loadExperts(),
      decoration: InputDecoration(
        hintText: l10n.searchExpertHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: _loadExperts,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._specialties.map((s) => Padding(
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
              )),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text('${l10n.filterYears}: $_minYears+'),
              selected: _minYears > 0,
              onSelected: (_) {
                setState(() {
                  _minYears = _minYears == 0 ? 5 : (_minYears == 5 ? 10 : 0);
                  _loadExperts();
                });
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _experts.length,
      itemBuilder: (context, i) {
        final e = _experts[i];
        final name = e['name'] as String? ?? '';
        final specialty = e['specialty'] as String? ?? '';
        final rating = ((e['rating'] ?? 0) as num).toDouble();
        final years = e['years_experience'] ?? 0;
        return KhibartiCard.expert(
          name: name,
          specialty: specialty,
          rating: rating,
          isVerified: (e['is_verified'] == 1 || e['is_verified'] == true),
          extraInfo: '$years سنة',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpertDetailScreen(expertId: e['id'] as int),
            ),
          ),
          action: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpertDetailScreen(expertId: e['id'] as int),
                ),
              ),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
              child: Text(l10n.book),
            ),
          ),
        );
      },
    );
  }
}
