import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  // Derives a stable color from categoryId until the category
  // feature is wired up with a real provider.
  static Color _colorFor(String categoryId) {
    final i = categoryId.hashCode.abs() % AppColors.categoryColors.length;
    return AppColors.categoryColors[i];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Something went wrong',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.error),
          ),
        ),
        data: (expenses) => expenses.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 96),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ExpenseCard(
                    expense: expense,
                    categoryColor: _colorFor(expense.categoryId),
                    onTap: () {},
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: tt.titleMedium?.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first expense',
            style: tt.bodySmall?.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
