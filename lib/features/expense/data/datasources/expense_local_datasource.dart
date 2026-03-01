import '../models/expense_model.dart';

abstract class ExpenseLocalDatasource {
  List<ExpenseModel> getAllExpenses();
  List<ExpenseModel> getExpensesByMonth(int year, int month);
  Future<void> addExpense(ExpenseModel model);
  Future<void> updateExpense(ExpenseModel model);
  Future<void> deleteExpense(String id);
}

class ExpenseLocalDatasourceImpl implements ExpenseLocalDatasource {
  @override
  List<ExpenseModel> getAllExpenses() => [];

  @override
  List<ExpenseModel> getExpensesByMonth(int year, int month) => [];

  @override
  Future<void> addExpense(ExpenseModel model) async {}

  @override
  Future<void> updateExpense(ExpenseModel model) async {}

  @override
  Future<void> deleteExpense(String id) async {}
}
