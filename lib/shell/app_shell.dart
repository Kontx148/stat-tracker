import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/theme/app_theme.dart';
import '../features/stats/data/stat_repository.dart';
import '../features/stats/presentation/stats_page.dart';
import '../features/calendar/presentation/weekly_page.dart';
import '../features/profile/presentation/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.repository});
  final StatRepository repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final statsKey = GlobalKey<StatsPageState>();
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      StatsPage(key: statsKey, repository: widget.repository),
      WeeklyPage(repository: widget.repository),
      const ProfilePage(),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beverage tracker',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              ['Stats', 'Week', 'Profile'][tab],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        actions: [
          if (tab == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                onPressed: () => statsKey.currentState?.openAddSheet(),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAddCircle,
                  size: 20,
                  color: AppTheme.accent,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff0b0f17), AppTheme.bg],
          ),
        ),
        child: pages[tab],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => tab = i),
              destinations: const [
                NavigationDestination(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics01),
                  label: 'Stats',
                ),
                NavigationDestination(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
                  label: 'Week',
                ),
                NavigationDestination(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedUser),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
