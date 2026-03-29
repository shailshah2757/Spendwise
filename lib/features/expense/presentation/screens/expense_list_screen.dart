import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monthlyExpensesProvider);
    final categoriesState = ref.watch(categoryNotifierProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    final categoryMap = <String, Category>{};
    categoriesState.whenData((cats) {
      for (final c in cats) {
        categoryMap[c.id] = c;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.expenses)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Something went wrong',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (expenses) => expenses.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 96),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  final cat = categoryMap[expense.categoryId];
                  return _SlidableExpenseCard(
                    expense: expense,
                    category: cat,
                    currencySymbol: currencySymbol,
                    onDelete: () => ref
                        .read(expenseNotifierProvider.notifier)
                        .delete(expense.id),
                  );
                },
              ),
      ),
    );
  }
}

class _SlidableExpenseCard extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final String currencySymbol;
  final VoidCallback onDelete;

  const _SlidableExpenseCard({
    required this.expense,
    this.category,
    required this.currencySymbol,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color = category != null ? Color(category!.colorValue) : AppColors.primary;
    final icon = category != null
        ? IconData(category!.iconCodePoint, fontFamily: 'MaterialIcons')
        : Icons.receipt_long_outlined;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor:
                isDark ? cs.error.withValues(alpha: 0.85) : cs.errorContainer,
            foregroundColor: isDark ? cs.onError : cs.onErrorContainer,
            borderRadius: BorderRadius.circular(16),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, size: 22),
                SizedBox(height: 4),
                Text('Delete',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      child: Card(
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: tt.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatFull(expense.date),
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormatter.formatCurrency(expense.amount, symbol: currencySymbol),
                  style: tt.titleSmall?.copyWith(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w700,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No expenses yet',
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first expense',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
