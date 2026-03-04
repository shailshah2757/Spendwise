import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDatasource {
  List<ExpenseModel> getAllExpenses();
  List<ExpenseModel> getExpensesByMonth(int year, int month);
  Future<void> addExpense(ExpenseModel model);
  Future<void> updateExpense(ExpenseModel model);
  Future<void> deleteExpense(String id);
}

class ExpenseLocalDatasourceImpl implements ExpenseLocalDatasource {
  final Box<ExpenseModel> _box;

  ExpenseLocalDatasourceImpl()
      : _box = Hive.box<ExpenseModel>(HiveBoxes.expenses);

  @override
  List<ExpenseModel> getAllExpenses() {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  List<ExpenseModel> getExpensesByMonth(int year, int month) {
    final list = _box.values
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> addExpense(ExpenseModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<void> updateExpense(ExpenseModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }
}
