import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDatasource {
  List<CategoryModel> getCategories();
  Future<void> addCategory(CategoryModel model);
  Future<void> deleteCategory(String id);
  Future<void> seedDefaults(List<Category> defaults);
}

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  final Box<CategoryModel> _box;

  CategoryLocalDatasourceImpl()
      : _box = Hive.box<CategoryModel>(HiveBoxes.categories);

  @override
  List<CategoryModel> getCategories() => _box.values.toList();

  @override
  Future<void> addCategory(CategoryModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> seedDefaults(List<Category> defaults) async {
    if (_box.isEmpty) {
      for (final c in defaults) {
        await _box.put(c.id, CategoryModel.fromEntity(c));
      }
    }
  }
}
