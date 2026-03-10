import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/presentation/providers/expense_provider.dart';
import '../../../settings/presentation/pages/category_budget_page.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final expensesState = ref.watch(monthlyExpensesProvider);
    final categoriesState = ref.watch(categoryNotifierProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final budget = ref.watch(monthlyBudgetProvider);
    final categoryBudgets = ref.watch(categoryBudgetsProvider);

    // Build category lookup map
    final categoryMap = <String, Category>{};
    categoriesState.whenData((cats) {
      for (final c in cats) {
        categoryMap[c.id] = c;
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar with greeting
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _greetingEmoji(),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('EEEE, dd MMM').format(DateTime.now()),
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- Budget Overview Card ---
                _BudgetHeroCard(
                  expensesState: expensesState,
                  budget: budget,
                  currencySymbol: currencySymbol,
                ),
                const SizedBox(height: 24),

                // --- Category Spending ---
                const _SectionHeader(title: 'Category Spending'),
                const SizedBox(height: 12),
                _CategorySpendingSection(
                  expensesState: expensesState,
                  categoryMap: categoryMap,
                  currencySymbol: currencySymbol,
                  categoryBudgets: categoryBudgets,
                ),
                const SizedBox(height: 24),

                // --- Recent Expenses ---
                const _SectionHeader(title: 'Recent Expenses'),
                const SizedBox(height: 12),
                _RecentExpensesSection(
                  expensesState: expensesState,
                  categoryMap: categoryMap,
                  currencySymbol: currencySymbol,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _greetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }
}

// --- Budget Hero Card ---

class _BudgetHeroCard extends StatelessWidget {
  final AsyncValue<List<Expense>> expensesState;
  final double budget;
  final String currencySymbol;

  const _BudgetHeroCard({
    required this.expensesState,
    required this.budget,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    double totalSpent = 0;
    expensesState.whenData((expenses) {
      for (final e in expenses) {
        totalSpent += e.amount;
      }
    });

    final progress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = budget > 0 && totalSpent > budget;
    final remaining = budget > 0 ? (budget - totalSpent) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Month',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('MMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            DateFormatter.formatCurrency(totalSpent, symbol: currencySymbol),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'spent so far',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          if (budget > 0) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget
                      ? const Color(0xFFFF8A80)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BudgetLabel(
                  label: 'Budget',
                  value: DateFormatter.formatCurrency(budget, symbol: currencySymbol),
                ),
                _BudgetLabel(
                  label: isOverBudget ? 'Over by' : 'Remaining',
                  value: DateFormatter.formatCurrency(
                    remaining.abs(),
                    symbol: currencySymbol,
                  ),
                  isWarning: isOverBudget,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetLabel extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _BudgetLabel({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isWarning ? const Color(0xFFFF8A80) : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// --- Category Spending Section ---

class _CategorySpendingSection extends StatelessWidget {
  final AsyncValue<List<Expense>> expensesState;
  final Map<String, Category> categoryMap;
  final String currencySymbol;
  final Map<String, double> categoryBudgets;

  const _CategorySpendingSection({
    required this.expensesState,
    required this.categoryMap,
    required this.currencySymbol,
    required this.categoryBudgets,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return expensesState.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Text('Failed to load'),
      data: (expenses) {
        // Aggregate by category
        final totals = <String, double>{};
        for (final e in expenses) {
          totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.amount;
        }

        if (totals.isEmpty) {
          return const _EmptySection(message: 'No category data yet');
        }

        final sorted = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: sorted.map((entry) {
                final cat = categoryMap[entry.key];
                final color = cat != null
                    ? Color(cat.colorValue)
                    : AppColors.primary;
                final name = cat?.name ?? 'Other';
                final icon = cat != null
                    ? IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons')
                    : Icons.receipt_long_outlined;

                final catBudget = categoryBudgets[entry.key] ?? 0;
                final hasBudget = catBudget > 0;
                final isOverBudget = hasBudget && entry.value > catBudget;

                final progress = hasBudget
                    ? (entry.value / catBudget).clamp(0.0, 1.0)
                    : (entry.value / sorted.first.value);

                final barColor = isOverBudget ? Colors.red.shade400 : color;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  hasBudget
                                      ? '${DateFormatter.formatCurrency(entry.value, symbol: currencySymbol)} / ${DateFormatter.formatCurrency(catBudget, symbol: currencySymbol)}'
                                      : DateFormatter.formatCurrency(entry.value, symbol: currencySymbol),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isOverBudget
                                        ? Colors.red.shade400
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5,
                                backgroundColor: cs.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(barColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

// --- Recent Expenses Section ---

class _RecentExpensesSection extends StatelessWidget {
  final AsyncValue<List<Expense>> expensesState;
  final Map<String, Category> categoryMap;
  final String currencySymbol;

  const _RecentExpensesSection({
    required this.expensesState,
    required this.categoryMap,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return expensesState.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Text('Failed to load'),
      data: (expenses) {
        final recent = expenses.take(10).toList();
        if (recent.isEmpty) {
          return const _EmptySection(message: 'No expenses yet');
        }

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: recent.asMap().entries.map((entry) {
                final e = entry.value;
                final isLast = entry.key == recent.length - 1;
                final cat = categoryMap[e.categoryId];
                final color = cat != null
                    ? Color(cat.colorValue)
                    : AppColors.primary;
                final icon = cat != null
                    ? IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons')
                    : Icons.receipt_long_outlined;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: tt.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormatter.formatFull(e.date),
                                  style: tt.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormatter.formatCurrency(e.amount,
                                symbol: currencySymbol),
                            style: tt.titleSmall?.copyWith(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 68,
                        endIndent: 16,
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

// --- Shared Helpers ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
