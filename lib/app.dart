import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/expense/presentation/screens/add_expense_screen.dart';
import 'features/expense/presentation/screens/expense_list_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'features/security/presentation/pages/lock_screen.dart';
import 'features/settings/presentation/pages/settings_screen.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/summary/presentation/pages/summary_page.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    ExpenseListScreen(),
    SummaryPage(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SecurityGate(
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          ),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: cs.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: AppStrings.home,
                selected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavBarItem(
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                label: AppStrings.expenses,
                selected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              const SizedBox(width: 48),
              _NavBarItem(
                icon: Icons.pie_chart_outline,
                selectedIcon: Icons.pie_chart,
                label: AppStrings.analytics,
                selected: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _NavBarItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: AppStrings.settings,
                selected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Security Gate ---
// Locks on cold start and every time app returns from background.

class SecurityGate extends ConsumerStatefulWidget {
  final Widget child;
  const SecurityGate({super.key, required this.child});

  @override
  ConsumerState<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends ConsumerState<SecurityGate>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _didInitialCheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lockEnabled = ref.read(appLockEnabledProvider);
      if (lockEnabled) {
        setState(() => _isLocked = true);
      }
      _didInitialCheck = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_didInitialCheck) return;
    final lockEnabled = ref.read(appLockEnabledProvider);
    if (!lockEnabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      setState(() => _isLocked = true);
    }
  }

  void _unlock() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return LockScreen(onUnlocked: _unlock);
    }
    return widget.child;
  }
}
