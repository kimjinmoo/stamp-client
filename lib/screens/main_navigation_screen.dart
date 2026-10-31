import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'profile_screen.dart';
import 'ranking_screen.dart';
import 'stamp_home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StampHomeScreen(),
    RankingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.canvas,
          border: const Border(
            top: BorderSide(color: AppColors.hairline, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: AppColors.canvas,
            indicatorColor: AppColors.primarySoft,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.confirmation_number_outlined, color: AppColors.muted),
                selectedIcon: Icon(Icons.confirmation_number_rounded, color: AppColors.primary),
                label: '스탬프 보드',
              ),
              NavigationDestination(
                icon: Icon(Icons.leaderboard_outlined, color: AppColors.muted),
                selectedIcon: Icon(Icons.leaderboard_rounded, color: AppColors.primary),
                label: '콤보 랭킹',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.muted),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: '내 정보',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
