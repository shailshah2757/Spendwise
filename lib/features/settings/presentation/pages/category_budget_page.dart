import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../providers/settings_provider.dart';

final categoryBudgetsProvider =
    StateProvider<Map<String, double>>((ref) {
  final box = Hive.box<double>(HiveBoxes.categoryBudgets);
  return Map.fromEntries(
    box.keys.cast<String>().map((k) => MapEntry(k, box.get(k) ?? 0)),
  );
});

class CategoryBudgetPage extends ConsumerWidget {
  const CategoryBudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryNotifierProvider);
    final budgets = ref.watch(categoryBudgetsProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categoryBudgets)),
      body: categoriesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final budget = budgets[cat.id] ?? 0;
              final color = Color(cat.colorValue);
              final icon = IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(
                    cat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    budget > 0
                        ? DateFormatter.formatCurrency(budget,
                            symbol: currencySymbol)
                        : 'No budget set',
                    style: TextStyle(
                      fontSize: 12,
                      color: budget > 0
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      _showBudgetDialog(context, ref, cat.id, cat.name, budget),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    String categoryId,
    String categoryName,
    double current,
  ) {
    final controller = TextEditingController(
      text: current > 0 ? current.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$categoryName Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Monthly budget amount',
          ),
          autofocus: true,
        ),
        actions: [
          if (current > 0)
            TextButton(
              onPressed: () async {
                final box = Hive.box<double>(HiveBoxes.categoryBudgets);
                await box.delete(categoryId);
                final updated = Map<String, double>.from(
                    ref.read(categoryBudgetsProvider));
                updated.remove(categoryId);
                ref.read(categoryBudgetsProvider.notifier).state = updated;
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              final amount =
                  double.tryParse(controller.text.trim()) ?? 0;
              final box = Hive.box<double>(HiveBoxes.categoryBudgets);
              if (amount > 0) {
                await box.put(categoryId, amount);
              } else {
                await box.delete(categoryId);
              }
              final updated = Map<String, double>.from(
                  ref.read(categoryBudgetsProvider));
              if (amount > 0) {
                updated[categoryId] = amount;
              } else {
                updated.remove(categoryId);
              }
              ref.read(categoryBudgetsProvider.notifier).state = updated;
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
