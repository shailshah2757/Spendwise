import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesByMonth {
  final ExpenseRepository repository;

  GetExpensesByMonth(this.repository);

  Future<List<Expense>> call(int year, int month) async => [];
}
