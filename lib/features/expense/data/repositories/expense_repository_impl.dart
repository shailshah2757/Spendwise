import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDatasource datasource;

  ExpenseRepositoryImpl(this.datasource);

  @override
  Future<List<Expense>> getAllExpenses() async {
    return datasource.getAllExpenses().map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    return datasource
        .getExpensesByMonth(year, month)
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await datasource.addExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await datasource.updateExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense(String id) async {
    await datasource.deleteExpense(id);
  }
}
