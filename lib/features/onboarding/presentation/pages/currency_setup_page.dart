import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/currencies.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../app.dart';

class CurrencySetupPage extends ConsumerStatefulWidget {
  const CurrencySetupPage({super.key});

  @override
  ConsumerState<CurrencySetupPage> createState() => _CurrencySetupPageState();
}

class _CurrencySetupPageState extends ConsumerState<CurrencySetupPage> {
  int _selectedIndex = -1;

  Future<void> _onContinue() async {
    if (_selectedIndex < 0) return;

    final currency = supportedCurrencies[_selectedIndex];
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setCurrency(currency.code, currency.symbol);
    await repo.setFirstLaunchDone();

    ref.read(currencySymbolProvider.notifier).state = currency.symbol;
    ref.read(currencyCodeProvider.notifier).state = currency.code;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(AppStrings.chooseCurrency, style: tt.headlineMedium),
              const SizedBox(height: 8),
              Text(
                AppStrings.currencySubtitle,
                style: tt.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final c = supportedCurrencies[index];
                    final selected = index == _selectedIndex;
                    return _CurrencyTile(
                      symbol: c.symbol,
                      code: c.code,
                      name: c.name,
                      selected: selected,
                      onTap: () => setState(() => _selectedIndex = index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex >= 0 ? _onContinue : null,
                  child: const Text(AppStrings.getStarted),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final String symbol;
  final String code;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.symbol,
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              code,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
