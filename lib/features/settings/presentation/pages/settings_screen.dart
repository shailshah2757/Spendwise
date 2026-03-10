import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../security/presentation/pages/pin_setup_page.dart';
import '../../../security/presentation/providers/security_provider.dart';
import '../providers/settings_provider.dart';
import 'category_budget_page.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _switchTheme(String newMode) {
    final current = ref.read(themeModeProvider);
    if (current == newMode) return;
    setThemeMode(ref.read(themeModeProvider.notifier), newMode);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final budget = ref.watch(monthlyBudgetProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final appLockEnabled = ref.watch(appLockEnabledProvider);
    final appLockType = ref.watch(appLockTypeProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Eagerly resolve biometric availability so it's ready for dialogs
    final biometricAsync = ref.watch(biometricAvailableProvider);
    final biometricAvailable = biometricAsync.valueOrNull ?? false;

    return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.settings)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // --- Appearance Section ---
            _SectionLabel(label: 'APPEARANCE', cs: cs),
            _SettingsCard(
              cs: cs,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          themeMode == 'dark'
                              ? Icons.dark_mode
                              : themeMode == 'light'
                                  ? Icons.light_mode
                                  : Icons.brightness_auto,
                          color: cs.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              themeMode == 'dark'
                                  ? 'Dark mode'
                                  : themeMode == 'light'
                                      ? 'Light mode'
                                      : 'System default',
                              style: TextStyle(
                                  fontSize: 12, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                  child: _ThemeSegmentedControl(
                    currentMode: themeMode,
                    onChanged: _switchTheme,
                  ),
                ),
              ],
            ),

            // --- Budget Section ---
            _SectionLabel(label: 'BUDGET', cs: cs),
            _SettingsCard(
              cs: cs,
              children: [
                _SettingsTile(
                  cs: cs,
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: cs.primary,
                  title: AppStrings.monthlyBudget,
                  subtitle: budget > 0
                      ? '$currencySymbol ${budget.toStringAsFixed(0)}'
                      : 'Not set',
                  onTap: () => _showBudgetDialog(context, ref, budget),
                ),
                _TileDivider(cs: cs),
                _SettingsTile(
                  cs: cs,
                  icon: Icons.pie_chart_outline,
                  iconColor: Colors.purple.shade400,
                  title: AppStrings.categoryBudgets,
                  subtitle: 'Set per-category limits',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CategoryBudgetPage()),
                  ),
                ),
              ],
            ),

            // --- Categories Section ---
            _SectionLabel(label: 'MANAGE', cs: cs),
            _SettingsCard(
              cs: cs,
              children: [
                _SettingsTile(
                  cs: cs,
                  icon: Icons.category_outlined,
                  iconColor: Colors.teal.shade400,
                  title: AppStrings.categories,
                  subtitle: 'Add or view categories',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryPage()),
                  ),
                ),
              ],
            ),

            // --- Security Section ---
            _SectionLabel(label: 'SECURITY', cs: cs),
            _SettingsCard(
              cs: cs,
              children: [
                _SettingsTile(
                  cs: cs,
                  icon: Icons.lock_outline,
                  iconColor: Colors.red.shade400,
                  title: AppStrings.appLock,
                  subtitle: appLockEnabled
                      ? 'Enabled (${appLockType == 'biometric' ? 'Biometric' : 'PIN'})'
                      : 'Disabled',
                  trailing: Switch.adaptive(
                    value: appLockEnabled,
                    activeTrackColor: cs.primary,
                    onChanged: (val) =>
                        _handleAppLockToggle(context, ref, val, biometricAvailable),
                  ),
                  onTap: () =>
                      _handleAppLockToggle(context, ref, !appLockEnabled, biometricAvailable),
                ),
                if (appLockEnabled) ...[
                  _TileDivider(cs: cs),
                  _SettingsTile(
                    cs: cs,
                    icon: Icons.fingerprint,
                    iconColor: Colors.blue.shade400,
                    title: 'Lock Method',
                    subtitle:
                        appLockType == 'biometric' ? 'Biometric' : 'PIN',
                    onTap: () => _showLockMethodPicker(context, ref, biometricAvailable),
                  ),
                ],
              ],
            ),

            // --- About Section ---
            _SectionLabel(label: 'INFO', cs: cs),
            _SettingsCard(
              cs: cs,
              children: [
                _SettingsTile(
                  cs: cs,
                  icon: Icons.info_outline,
                  iconColor: cs.onSurfaceVariant,
                  title: AppStrings.about,
                  subtitle: 'v1.0.0',
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
    );
  }


  void _showBudgetDialog(
      BuildContext context, WidgetRef ref, double current) {
    final controller = TextEditingController(
      text: current > 0 ? current.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.monthlyBudget),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter budget amount',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              final amount =
                  double.tryParse(controller.text.trim()) ?? 0;
              final repo = ref.read(settingsRepositoryProvider);
              await repo.setMonthlyBudget(amount);
              ref.read(monthlyBudgetProvider.notifier).state = amount;
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAppLockToggle(
    BuildContext context,
    WidgetRef ref,
    bool enable,
    bool biometricAvailable,
  ) async {
    if (enable) {
      if (!context.mounted) return;
      final cs = Theme.of(context).colorScheme;

      final method = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Text(
                    'Choose Lock Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dialpad),
                  title: const Text('PIN'),
                  subtitle:
                      const Text('Set a 4-digit PIN to lock the app'),
                  onTap: () => Navigator.of(ctx).pop('pin'),
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biometric'),
                  subtitle: biometricAvailable
                      ? const Text('Use fingerprint or face to unlock')
                      : Text(
                          'Not available on this device',
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                  enabled: biometricAvailable,
                  onTap: biometricAvailable
                      ? () => Navigator.of(ctx).pop('biometric')
                      : null,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );

      if (method == null) return;

      if (method == 'pin') {
        if (!context.mounted) return;
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const PinSetupPage()),
        );
        if (result != true) return;
      } else if (method == 'biometric') {
        final repo = ref.read(settingsRepositoryProvider);
        await repo.setAppLockType('biometric');
        await repo.setAppLockEnabled(true);
        ref.read(appLockEnabledProvider.notifier).state = true;
        ref.read(appLockTypeProvider.notifier).state = 'biometric';
      }
    } else {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setAppLockEnabled(false);
      ref.read(appLockEnabledProvider.notifier).state = false;
    }
  }

  void _showLockMethodPicker(BuildContext context, WidgetRef ref, bool biometricAvailable) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dialpad),
                title: const Text('PIN'),
                trailing: ref.read(appLockTypeProvider) == 'pin'
                    ? Icon(Icons.check_circle, color: cs.primary)
                    : null,
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final result =
                      await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => const PinSetupPage()),
                  );
                  if (result == true) {
                    ref.read(appLockTypeProvider.notifier).state = 'pin';
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Biometric'),
                subtitle: biometricAvailable
                    ? null
                    : Text(
                        'Not available on this device',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                enabled: biometricAvailable,
                trailing: ref.read(appLockTypeProvider) == 'biometric'
                    ? Icon(Icons.check_circle, color: cs.primary)
                    : null,
                onTap: biometricAvailable
                    ? () async {
                        final repo =
                            ref.read(settingsRepositoryProvider);
                        await repo.setAppLockType('biometric');
                        ref.read(appLockTypeProvider.notifier).state =
                            'biometric';
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      }
                    : null,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary, cs.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A simple and beautiful expense tracker to help you manage your daily finances. '
              'Track spending, set budgets, view analytics, and stay on top of your money.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Built with Flutter',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Theme Segmented Control ---

class _ThemeSegmentedControl extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onChanged;

  const _ThemeSegmentedControl({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _SegmentOption(
            icon: Icons.light_mode,
            label: 'Light',
            selected: currentMode == 'light',
            onTap: () => onChanged('light'),
          ),
          _SegmentOption(
            icon: Icons.brightness_auto,
            label: 'System',
            selected: currentMode == 'system',
            onTap: () => onChanged('system'),
          ),
          _SegmentOption(
            icon: Icons.dark_mode,
            label: 'Dark',
            selected: currentMode == 'dark',
            onTap: () => onChanged('dark'),
          ),
        ],
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Shared widgets ---

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme cs;
  const _SettingsCard({required this.children, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ColorScheme cs;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.cs,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class _TileDivider extends StatelessWidget {
  final ColorScheme cs;
  const _TileDivider({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: cs.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
