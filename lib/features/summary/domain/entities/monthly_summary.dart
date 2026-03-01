import 'package:equatable/equatable.dart';

class CategoryTotal extends Equatable {
  final String categoryId;
  final String categoryName;
  final int colorValue;
  final double total;

  const CategoryTotal({
    required this.categoryId,
    required this.categoryName,
    required this.colorValue,
    required this.total,
  });

  @override
  List<Object> get props => [categoryId, total];
}

class MonthlySummary extends Equatable {
  final int year;
  final int month;
  final double totalAmount;
  final List<CategoryTotal> byCategory;

  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.byCategory,
  });

  @override
  List<Object> get props => [year, month, totalAmount, byCategory];
}
