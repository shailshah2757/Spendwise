import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Future<List<Category>> getCategories() async {
    return datasource.getCategories().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    await datasource.addCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await datasource.deleteCategory(id);
  }
}
