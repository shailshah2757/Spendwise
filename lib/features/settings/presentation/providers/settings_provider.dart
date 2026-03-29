import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsDatasourceProvider = Provider<SettingsLocalDatasource>(
  (_) => SettingsLocalDatasourceImpl(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.read(settingsDatasourceProvider)),
);

final currencySymbolProvider = StateProvider<String>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.getCurrencySymbol();
});

final currencyCodeProvider = StateProvider<String>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.getCurrency();
});

final isFirstLaunchProvider = Provider<bool>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.isFirstLaunch();
});

final monthlyBudgetProvider = StateProvider<double>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.getMonthlyBudget();
});

final appLockEnabledProvider = StateProvider<bool>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.isAppLockEnabled();
});

final appLockTypeProvider = StateProvider<String>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.getAppLockType();
});

