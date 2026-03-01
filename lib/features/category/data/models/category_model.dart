import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint;

  @HiveField(3)
  final int colorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  factory CategoryModel.fromEntity(Category c) => CategoryModel(
        id: c.id,
        name: c.name,
        iconCodePoint: c.iconCodePoint,
        colorValue: c.colorValue,
      );

  Category toEntity() => Category(
        id: id,
        name: name,
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
      );
}
