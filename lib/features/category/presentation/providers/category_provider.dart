import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';

// --- Infrastructure providers ---

final categoryDatasourceProvider = Provider<CategoryLocalDatasource>(
  (_) => CategoryLocalDatasourceImpl(),
);

final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepositoryImpl(ref.read(categoryDatasourceProvider)),
);

// --- Use case providers ---

final getCategoriesProvider = Provider(
  (ref) => GetCategories(ref.read(categoryRepositoryProvider)),
);

final addCategoryProvider = Provider(
  (ref) => AddCategory(ref.read(categoryRepositoryProvider)),
);

final deleteCategoryProvider = Provider(
  (ref) => DeleteCategory(ref.read(categoryRepositoryProvider)),
);

// --- State notifier ---

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GetCategories _getCategories;
  final AddCategory _addCategory;
  final DeleteCategory _deleteCategory;
  final CategoryLocalDatasource _datasource;

  CategoryNotifier({
    required GetCategories getCategories,
    required AddCategory addCategory,
    required DeleteCategory deleteCategory,
    required CategoryLocalDatasource datasource,
  })  : _getCategories = getCategories,
        _addCategory = addCategory,
        _deleteCategory = deleteCategory,
        _datasource = datasource,
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _datasource.seedDefaults(defaultCategories);
    await load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final cats = await _getCategories();
      state = AsyncValue.data(cats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    await _deleteCategory(id);
    await load();
  }

  Future<void> add(String name, int iconCodePoint, int colorValue) async {
    final category = Category(
      id: const Uuid().v4(),
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
    );
    await _addCategory(category);
    await load();
  }
}

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
  (ref) => CategoryNotifier(
    getCategories: ref.read(getCategoriesProvider),
    addCategory: ref.read(addCategoryProvider),
    deleteCategory: ref.read(deleteCategoryProvider),
    datasource: ref.read(categoryDatasourceProvider),
  ),
);
