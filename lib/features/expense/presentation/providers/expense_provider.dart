import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_month.dart';
import '../../domain/usecases/update_expense.dart';

// --- Infrastructure providers ---

final expenseDatasourceProvider = Provider<ExpenseLocalDatasource>(
  (_) => ExpenseLocalDatasourceImpl(),
);

final expenseRepositoryProvider = Provider(
  (ref) => ExpenseRepositoryImpl(ref.read(expenseDatasourceProvider)),
);

// --- Use case providers ---

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

final getExpensesByMonthProvider = Provider(
  (ref) => GetExpensesByMonth(ref.read(expenseRepositoryProvider)),
);

// --- State notifier ---

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final GetExpenses _getExpenses;
  final AddExpense _addExpense;
  final DeleteExpense _deleteExpense;
  final UpdateExpense _updateExpense;

  ExpenseNotifier({
    required GetExpenses getExpenses,
    required AddExpense addExpense,
    required DeleteExpense deleteExpense,
    required UpdateExpense updateExpense,
  })  : _getExpenses = getExpenses,
        _addExpense = addExpense,
        _deleteExpense = deleteExpense,
        _updateExpense = updateExpense,
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _getExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Expense expense) async {
    await _addExpense(expense);
    await load();
  }

  Future<void> delete(String id) async {
    await _deleteExpense(id);
    await load();
  }

  Future<void> update(Expense expense) async {
    await _updateExpense(expense);
    await load();
  }
}

final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>(
  (ref) => ExpenseNotifier(
    getExpenses: ref.read(getExpensesProvider),
    addExpense: ref.read(addExpenseProvider),
    deleteExpense: ref.read(deleteExpenseProvider),
    updateExpense: ref.read(updateExpenseProvider),
  ),
);

// --- Monthly expenses provider ---

final monthlyExpensesProvider =
    FutureProvider.autoDispose<List<Expense>>((ref) async {
  ref.watch(expenseNotifierProvider);
  final now = DateTime.now();
  final usecase = ref.read(getExpensesByMonthProvider);
  return usecase(now.year, now.month);
});
