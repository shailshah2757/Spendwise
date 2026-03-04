import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/currencies.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../security/presentation/pages/pin_setup_page.dart';
import '../../../security/presentation/providers/security_provider.dart';
import '../providers/settings_provider.dart';
import 'category_budget_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyCode = ref.watch(currencyCodeProvider);
    final budget = ref.watch(monthlyBudgetProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final appLockEnabled = ref.watch(appLockEnabledProvider);
    final appLockType = ref.watch(appLockTypeProvider);
    final biometricAsync = ref.watch(biometricAvailableProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // --- Budget & Currency Section ---
          const _SectionLabel(label: 'BUDGET & CURRENCY'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primary,
                title: AppStrings.monthlyBudget,
                subtitle: budget > 0
                    ? '$currencySymbol ${budget.toStringAsFixed(0)}'
                    : 'Not set',
                onTap: () => _showBudgetDialog(context, ref, budget),
              ),
              const _TileDivider(),
              _SettingsTile(
                icon: Icons.currency_exchange,
                iconColor: Colors.orange.shade600,
                title: AppStrings.currency,
                subtitle: currencyCode,
                onTap: () => _showCurrencyPicker(context, ref),
              ),
              const _TileDivider(),
              _SettingsTile(
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
          const _SectionLabel(label: 'MANAGE'),
          _SettingsCard(
            children: [
              _SettingsTile(
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
          const _SectionLabel(label: 'SECURITY'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                iconColor: Colors.red.shade400,
                title: AppStrings.appLock,
                subtitle: appLockEnabled
                    ? 'Enabled (${appLockType == 'biometric' ? 'Biometric' : 'PIN'})'
                    : 'Disabled',
                trailing: Switch.adaptive(
                  value: appLockEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) =>
                      _handleAppLockToggle(context, ref, val, appLockType),
                ),
                onTap: () =>
                    _handleAppLockToggle(context, ref, !appLockEnabled, appLockType),
              ),
              if (appLockEnabled) ...[
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.fingerprint,
                  iconColor: Colors.blue.shade400,
                  title: 'Lock Method',
                  subtitle: appLockType == 'biometric' ? 'Biometric' : 'PIN',
                  onTap: () => _showLockMethodPicker(
                      context, ref, biometricAsync),
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.timer_outlined,
                  iconColor: Colors.amber.shade600,
                  title: 'Lock Timeout',
                  subtitle:
                      '${ref.watch(lockTimeoutProvider)} min after background',
                  onTap: () => _showTimeoutPicker(context, ref),
                ),
              ],
            ],
          ),

          // --- About Section ---
          const _SectionLabel(label: 'INFO'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                iconColor: Colors.grey.shade500,
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

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: supportedCurrencies.length,
              itemBuilder: (ctx, i) {
                final c = supportedCurrencies[i];
                final selected = ref.read(currencyCodeProvider) == c.code;
                return ListTile(
                  leading:
                      Text(c.symbol, style: const TextStyle(fontSize: 20)),
                  title: Text(c.name),
                  subtitle: Text(c.code),
                  trailing: selected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary)
                      : null,
                  onTap: () async {
                    final repo = ref.read(settingsRepositoryProvider);
                    await repo.setCurrency(c.code, c.symbol);
                    ref.read(currencySymbolProvider.notifier).state = c.symbol;
                    ref.read(currencyCodeProvider.notifier).state = c.code;
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                );
              },
            ),
          ),
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
    String currentType,
  ) async {
    if (enable) {
      // Navigate to PIN setup
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PinSetupPage()),
      );
      // result is true if PIN was set successfully
      if (result != true) return;
    } else {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setAppLockEnabled(false);
      ref.read(appLockEnabledProvider.notifier).state = false;
    }
  }

  void _showLockMethodPicker(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> biometricAsync,
  ) {
    final biometricAvailable = biometricAsync.valueOrNull ?? false;

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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dialpad),
                title: const Text('PIN'),
                trailing: ref.read(appLockTypeProvider) == 'pin'
                    ? const Icon(Icons.check_circle,
                        color: AppColors.primary)
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
                    ? const Icon(Icons.check_circle,
                        color: AppColors.primary)
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

  void _showTimeoutPicker(BuildContext context, WidgetRef ref) {
    final options = [1, 2, 5, 10];
    final current = ref.read(lockTimeoutProvider);

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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ...options.map((min) => ListTile(
                    title: Text('$min minute${min > 1 ? 's' : ''}'),
                    trailing: current == min
                        ? const Icon(Icons.check_circle,
                            color: AppColors.primary)
                        : null,
                    onTap: () async {
                      final repo =
                          ref.read(settingsRepositoryProvider);
                      await repo.setLockTimeoutMinutes(min);
                      ref.read(lockTimeoutProvider.notifier).state = min;
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: [
        const Text(
          'A simple and beautiful expense tracker to help you manage your finances.',
        ),
      ],
    );
  }
}

// --- Shared widgets ---

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant),
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

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
