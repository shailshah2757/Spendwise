import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;
  DeleteCategory(this.repository);

  Future<void> call(String id) => repository.deleteCategory(id);
}
