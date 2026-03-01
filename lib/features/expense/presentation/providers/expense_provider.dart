import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';

final expenseDatasourceProvider = Provider<ExpenseLocalDatasource>(
  (_) => ExpenseLocalDatasourceImpl(),
);

final expenseRepositoryProvider = Provider(
  (ref) => ExpenseRepositoryImpl(ref.read(expenseDatasourceProvider)),
);

final getExpensesProvider = Provider(
  (ref) => GetExpenses(ref.read(expenseRepositoryProvider)),
);

final addExpenseProvider = Provider(
  (ref) => AddExpense(ref.read(expenseRepositoryProvider)),
);

final deleteExpenseProvider = Provider(
  (ref) => DeleteExpense(ref.read(expenseRepositoryProvider)),
);

final updateExpenseProvider = Provider(
  (ref) => UpdateExpense(ref.read(expenseRepositoryProvider)),
);

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  ExpenseNotifier() : super(const AsyncValue.data([]));
}

final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>(
  (ref) => ExpenseNotifier(),
);
