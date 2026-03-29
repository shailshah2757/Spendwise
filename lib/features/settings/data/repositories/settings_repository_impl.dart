import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource datasource;

  SettingsRepositoryImpl(this.datasource);

  @override
  String getCurrency() => datasource.getCurrency();

  @override
  String getCurrencySymbol() => datasource.getCurrencySymbol();

  @override
  Future<void> setCurrency(String code, String symbol) =>
      datasource.setCurrency(code, symbol);

  @override
  bool isFirstLaunch() => datasource.isFirstLaunch();

  @override
  Future<void> setFirstLaunchDone() => datasource.setFirstLaunchDone();

  @override
  double getMonthlyBudget() => datasource.getMonthlyBudget();

  @override
  Future<void> setMonthlyBudget(double amount) =>
      datasource.setMonthlyBudget(amount);

  @override
  bool isAppLockEnabled() => datasource.isAppLockEnabled();

  @override
  Future<void> setAppLockEnabled(bool enabled) =>
      datasource.setAppLockEnabled(enabled);

  @override
  String getAppLockType() => datasource.getAppLockType();

  @override
  Future<void> setAppLockType(String type) =>
      datasource.setAppLockType(type);

  @override
  String? getAppLockPin() => datasource.getAppLockPin();

  @override
  Future<void> setAppLockPin(String pin) =>
      datasource.setAppLockPin(pin);

  @override
  int getLockTimeoutMinutes() => datasource.getLockTimeoutMinutes();

  @override
  Future<void> setLockTimeoutMinutes(int minutes) =>
      datasource.setLockTimeoutMinutes(minutes);
}
