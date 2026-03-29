import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../constants/hive_boxes.dart';

/// 'light' | 'dark' | 'system'
final themeModeProvider = StateProvider<String>((ref) {
  final box = Hive.box(HiveBoxes.settings);
  // Migrate from old bool-based isDarkMode key
  if (box.containsKey('isDarkMode') && !box.containsKey('themeMode')) {
    final wasDark = box.get('isDarkMode', defaultValue: false) as bool;
    final mode = wasDark ? 'dark' : 'light';
    box.put('themeMode', mode);
    box.delete('isDarkMode');
    return mode;
  }
  return box.get('themeMode', defaultValue: 'system') as String;
});

Future<void> setThemeMode(
    StateController<String> notifier, String mode) async {
  notifier.state = mode;
  final box = Hive.box(HiveBoxes.settings);
  box.put('themeMode', mode);
}

ThemeMode resolveThemeMode(String mode) {
  switch (mode) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}
