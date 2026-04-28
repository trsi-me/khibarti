import 'package:flutter/material.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/theme/app_theme.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/home_screen.dart';
import 'package:khibarti/screens/explore_screen.dart';
import 'package:khibarti/screens/sessions_screen.dart';
import 'package:khibarti/screens/profile_screen.dart';
import 'package:khibarti/screens/settings_screen.dart';
import 'package:khibarti/screens/expert_home_screen.dart';
import 'package:khibarti/screens/expert_sessions_screen.dart';
import 'package:khibarti/screens/company_home_screen.dart';
import 'package:khibarti/screens/company_experts_screen.dart';
import 'package:khibarti/screens/admin/admin_dashboard_screen.dart';
import 'package:khibarti/screens/admin/admin_users_screen.dart';
import 'package:khibarti/screens/admin/admin_sessions_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  String get _role =>
      AppState.currentUser?['role_name'] as String? ?? 'student';

  List<Widget> get _screens {
    switch (_role) {
      case 'admin':
        return const [
          AdminDashboardScreen(),
          AdminUsersScreen(),
          AdminSessionsScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ];
      case 'expert':
        return const [
          ExpertHomeScreen(),
          ExpertSessionsScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ];
      case 'company':
        return const [
          CompanyHomeScreen(),
          CompanyExpertsScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ];
      default:
        return const [
          HomeScreen(),
          ExploreScreen(),
          SessionsScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isExpert = _role == 'expert';
    final isCompany = _role == 'company';
    final isAdmin = _role == 'admin';

    final navIndex = _currentIndex.clamp(0, _screens.length - 1);
    return Scaffold(
      body: IndexedStack(index: navIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildNavItems(
                l10n,
                isExpert,
                isCompany,
                isAdmin,
                navIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(
    AppLocalizations l10n,
    bool isExpert,
    bool isCompany,
    bool isAdmin,
    int navIndex,
  ) {
    final List<({IconData icon, String label})> items = isAdmin
        ? [
            (icon: Icons.dashboard_customize_outlined, label: l10n.navBarAdminDash),
            (icon: Icons.groups_outlined, label: l10n.navBarAdminUsers),
            (icon: Icons.event_available_outlined, label: l10n.navBarAdminSessions),
            (icon: Icons.person_outline, label: l10n.navBarProfile),
            (icon: Icons.settings_outlined, label: l10n.navBarSettings),
          ]
        : isExpert
            ? [
                (icon: Icons.dashboard_outlined, label: l10n.navBarHome),
                (icon: Icons.calendar_today_outlined, label: l10n.navBarExpertSessions),
                (icon: Icons.person_outline, label: l10n.navBarProfile),
                (icon: Icons.settings_outlined, label: l10n.navBarSettings),
              ]
            : isCompany
                ? [
                    (icon: Icons.dashboard_outlined, label: l10n.navBarHome),
                    (icon: Icons.people_outline, label: l10n.navBarCompanyExperts),
                    (icon: Icons.person_outline, label: l10n.navBarProfile),
                    (icon: Icons.settings_outlined, label: l10n.navBarSettings),
                  ]
                : [
                    (icon: Icons.home_outlined, label: l10n.navBarHome),
                    (icon: Icons.search_outlined, label: l10n.navBarExplore),
                    (icon: Icons.calendar_today_outlined, label: l10n.navBarSessions),
                    (icon: Icons.person_outline, label: l10n.navBarProfile),
                    (icon: Icons.settings_outlined, label: l10n.navBarSettings),
                  ];
    return List.generate(items.length, (i) {
      final selected = i == navIndex;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _currentIndex = i),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i].icon,
                    size: 26,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.1,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
