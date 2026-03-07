import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/currencies.dart';
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
  final GlobalKey _themeToggleKey = GlobalKey();
  final GlobalKey _repaintKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  Future<void> _toggleTheme() async {
    final isDark = ref.read(themeModeProvider);
    final newIsDark = !isDark;

    // Get toggle button position for circular reveal origin
    final renderBox =
        _themeToggleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      await setThemeMode(ref.read(themeModeProvider.notifier), newIsDark);
      return;
    }

    final position = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );

    // Capture current screen as image
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      await setThemeMode(ref.read(themeModeProvider.notifier), newIsDark);
      return;
    }

    final image = await boundary.toImage(pixelRatio: 1.5);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    image.dispose();
    if (byteData == null) {
      await setThemeMode(ref.read(themeModeProvider.notifier), newIsDark);
      return;
    }
    final pngBytes = byteData.buffer.asUint8List();

    // Switch theme immediately
    await setThemeMode(ref.read(themeModeProvider.notifier), newIsDark);

    // Show overlay with old screenshot + circular reveal punching through it
    if (!mounted) return;
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _CircularRevealTransition(
        screenshot: pngBytes,
        center: position,
        onComplete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currencyCode = ref.watch(currencyCodeProvider);
    final budget = ref.watch(monthlyBudgetProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final appLockEnabled = ref.watch(appLockEnabledProvider);
    final appLockType = ref.watch(appLockTypeProvider);
    final biometricAsync = ref.watch(biometricAvailableProvider);
    final isDark = ref.watch(themeModeProvider);

    return RepaintBoundary(
      key: _repaintKey,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.settings)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // --- Appearance Section ---
            _SectionLabel(label: 'APPEARANCE', cs: cs),
            _SettingsCard(
              cs: cs,
              children: [
                _SettingsTile(
                  cs: cs,
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  iconColor:
                      isDark ? Colors.indigo.shade300 : Colors.amber.shade600,
                  title: 'Theme',
                  subtitle: isDark ? 'Dark mode' : 'Light mode',
                  trailing: GestureDetector(
                    key: _themeToggleKey,
                    onTap: _toggleTheme,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 30,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: isDark
                            ? cs.primary
                            : cs.surfaceContainerHighest,
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: isDark
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white : cs.primary,
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            size: 14,
                            color: isDark ? cs.primary : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTap: _toggleTheme,
                ),
              ],
            ),

            // --- Budget & Currency Section ---
            _SectionLabel(label: 'BUDGET & CURRENCY', cs: cs),
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
                  icon: Icons.currency_exchange,
                  iconColor: Colors.orange.shade600,
                  title: AppStrings.currency,
                  subtitle: currencyCode,
                  onTap: () => _showCurrencyPicker(context, ref),
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
                        _handleAppLockToggle(context, ref, val, appLockType),
                  ),
                  onTap: () => _handleAppLockToggle(
                      context, ref, !appLockEnabled, appLockType),
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
                    onTap: () => _showLockMethodPicker(
                        context, ref, biometricAsync),
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.3),
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
                      ? Icon(Icons.check_circle,
                          color: Theme.of(ctx).colorScheme.primary)
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
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PinSetupPage()),
      );
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
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, cs.primaryContainer],
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

// --- Circular Reveal Transition ---

class _CircularRevealTransition extends StatefulWidget {
  final Uint8List screenshot;
  final Offset center;
  final VoidCallback onComplete;

  const _CircularRevealTransition({
    required this.screenshot,
    required this.center,
    required this.onComplete,
  });

  @override
  State<_CircularRevealTransition> createState() =>
      _CircularRevealTransitionState();
}

class _CircularRevealTransitionState extends State<_CircularRevealTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = _maxDistance(widget.center, size);

    return AnimatedBuilder(
      animation:
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      builder: (context, child) {
        return ClipPath(
          clipper: _InvertedCircleClipper(
            center: widget.center,
            radius: maxRadius * _controller.value,
          ),
          child: SizedBox.expand(
            child: Image.memory(
              widget.screenshot,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        );
      },
    );
  }

  double _maxDistance(Offset center, Size size) {
    final dx = [center.dx, size.width - center.dx]
        .reduce((a, b) => a > b ? a : b);
    final dy = [center.dy, size.height - center.dy]
        .reduce((a, b) => a > b ? a : b);
    return Offset(dx, dy).distance;
  }
}

class _InvertedCircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _InvertedCircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant _InvertedCircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
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
