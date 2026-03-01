import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;

  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  @override
  List<Object> get props => [id, name, iconCodePoint, colorValue];
}

/// Seeded default categories
final defaultCategories = [
  const Category(id: 'food',        name: 'Food & Dining',   iconCodePoint: 0xe56c, colorValue: 0xFFFF6384),
  const Category(id: 'transport',   name: 'Transport',       iconCodePoint: 0xe531, colorValue: 0xFF36A2EB),
  const Category(id: 'shopping',    name: 'Shopping',        iconCodePoint: 0xe59c, colorValue: 0xFFFFCE56),
  const Category(id: 'health',      name: 'Health',          iconCodePoint: 0xe3f3, colorValue: 0xFF4BC0C0),
  const Category(id: 'bills',       name: 'Bills',           iconCodePoint: 0xe8b0, colorValue: 0xFF9966FF),
  const Category(id: 'entertain',   name: 'Entertainment',   iconCodePoint: 0xe02c, colorValue: 0xFFFF9F40),
  const Category(id: 'other',       name: 'Other',           iconCodePoint: 0xe8b8, colorValue: 0xFFB0B0B0),
];
