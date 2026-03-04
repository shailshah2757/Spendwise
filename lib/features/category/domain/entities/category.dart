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
/// Icon code points reference Material Icons (fontFamily: 'MaterialIcons')
final defaultCategories = [
  const Category(id: 'food',        name: 'Food & Dining',   iconCodePoint: 0xe56c, colorValue: 0xFFFF6384),  // restaurant
  const Category(id: 'transport',   name: 'Transport',       iconCodePoint: 0xe531, colorValue: 0xFF36A2EB),  // directions_car
  const Category(id: 'shopping',    name: 'Shopping',        iconCodePoint: 0xf37e, colorValue: 0xFFFFCE56),  // shopping_bag
  const Category(id: 'health',      name: 'Health',          iconCodePoint: 0xe548, colorValue: 0xFF4BC0C0),  // local_hospital
  const Category(id: 'bills',       name: 'Bills',           iconCodePoint: 0xe8b0, colorValue: 0xFF9966FF),  // receipt
  const Category(id: 'entertain',   name: 'Entertainment',   iconCodePoint: 0xe40f, colorValue: 0xFFFF9F40),  // sports_esports
  const Category(id: 'other',       name: 'Other',           iconCodePoint: 0xe8b8, colorValue: 0xFFB0B0B0),  // more_horiz
];
