import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants/hive_boxes.dart';
import 'features/category/data/models/category_model.dart';
import 'features/expense/data/models/expense_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  // Open boxes
  await Future.wait([
    Hive.openBox<ExpenseModel>(HiveBoxes.expenses),
    Hive.openBox<CategoryModel>(HiveBoxes.categories),
  ]);

  runApp(const ExpenseTrackerApp());
}
