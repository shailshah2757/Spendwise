import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDatasource datasource;

  ExpenseRepositoryImpl(this.datasource);

  @override
  Future<List<Expense>> getAllExpenses() async => [];

  @override
  Future<List<Expense>> getExpensesByMonth(int year, int month) async => [];

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}
}
