import '../../../category/domain/repositories/category_repository.dart';
import '../../../expense/domain/repositories/expense_repository.dart';
import '../entities/monthly_summary.dart';

class GetMonthlySummary {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;

  GetMonthlySummary({
    required this.expenseRepository,
    required this.categoryRepository,
  });

  Future<MonthlySummary> call(int year, int month) async {
    final expenses = await expenseRepository.getExpensesByMonth(year, month);
    final categories = await categoryRepository.getCategories();

    final categoryMap = {for (final c in categories) c.id: c};

    final totalsMap = <String, double>{};
    for (final e in expenses) {
      totalsMap[e.categoryId] = (totalsMap[e.categoryId] ?? 0) + e.amount;
    }

    final byCategory = totalsMap.entries.map((entry) {
      final cat = categoryMap[entry.key];
      return CategoryTotal(
        categoryId: entry.key,
        categoryName: cat?.name ?? 'Unknown',
        colorValue: cat?.colorValue ?? 0xFFB0B0B0,
        total: entry.value,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return MonthlySummary(
      year: year,
      month: month,
      totalAmount: total,
      byCategory: byCategory,
    );
  }
}
