import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../constants/hive_boxes.dart';

/// true = dark mode, false = light mode
final themeModeProvider = StateProvider<bool>((ref) {
  final box = Hive.box(HiveBoxes.settings);
  return box.get('isDarkMode', defaultValue: false) as bool;
});

Future<void> setThemeMode(StateController<bool> notifier, bool isDark) async {
  final box = Hive.box(HiveBoxes.settings);
  await box.put('isDarkMode', isDark);
  notifier.state = isDark;
}
