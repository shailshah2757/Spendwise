import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../expense/presentation/providers/expense_provider.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/usecases/get_monthly_summary.dart';

final getMonthlySummaryProvider = Provider((ref) => GetMonthlySummary(
      expenseRepository: ref.read(expenseRepositoryProvider),
      categoryRepository: ref.read(categoryRepositoryProvider),
    ));

// Tracks which month/year is currently selected in the summary page
final selectedMonthProvider = StateProvider<DateTime>(
  (_) => DateTime.now(),
);

final monthlySummaryProvider =
    FutureProvider.autoDispose<MonthlySummary>((ref) async {
  // Re-fetch whenever expenses change
  ref.watch(expenseNotifierProvider);
  final selected = ref.watch(selectedMonthProvider);
  final usecase = ref.read(getMonthlySummaryProvider);
  return usecase(selected.year, selected.month);
});
