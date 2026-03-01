import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? notes;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes,
  });

  factory ExpenseModel.fromEntity(Expense expense) => ExpenseModel(
        id: expense.id,
        title: expense.title,
        amount: expense.amount,
        categoryId: expense.categoryId,
        date: expense.date,
        notes: expense.notes,
      );

  Expense toEntity() => Expense(
        id: id,
        title: title,
        amount: amount,
        categoryId: categoryId,
        date: date,
        notes: notes,
      );
}
