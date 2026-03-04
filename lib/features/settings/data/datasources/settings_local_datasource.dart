import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';

abstract class SettingsLocalDatasource {
  String getCurrency();
  String getCurrencySymbol();
  Future<void> setCurrency(String code, String symbol);
  bool isFirstLaunch();
  Future<void> setFirstLaunchDone();
  double getMonthlyBudget();
  Future<void> setMonthlyBudget(double amount);
  bool isAppLockEnabled();
  Future<void> setAppLockEnabled(bool enabled);
  String getAppLockType();
  Future<void> setAppLockType(String type);
  String? getAppLockPin();
  Future<void> setAppLockPin(String pin);
  int getLockTimeoutMinutes();
  Future<void> setLockTimeoutMinutes(int minutes);
}

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  final Box _box;

  SettingsLocalDatasourceImpl()
      : _box = Hive.box(HiveBoxes.settings);

  @override
  String getCurrency() => _box.get('currency', defaultValue: 'USD') as String;

  @override
  String getCurrencySymbol() =>
      _box.get('currencySymbol', defaultValue: '\$') as String;

  @override
  Future<void> setCurrency(String code, String symbol) async {
    await _box.put('currency', code);
    await _box.put('currencySymbol', symbol);
  }

  @override
  bool isFirstLaunch() => _box.get('isFirstLaunch', defaultValue: true) as bool;

  @override
  Future<void> setFirstLaunchDone() async {
    await _box.put('isFirstLaunch', false);
  }

  @override
  double getMonthlyBudget() =>
      (_box.get('monthlyBudget', defaultValue: 0.0) as num).toDouble();

  @override
  Future<void> setMonthlyBudget(double amount) async {
    await _box.put('monthlyBudget', amount);
  }

  @override
  bool isAppLockEnabled() =>
      _box.get('appLockEnabled', defaultValue: false) as bool;

  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    await _box.put('appLockEnabled', enabled);
  }

  @override
  String getAppLockType() =>
      _box.get('appLockType', defaultValue: 'pin') as String;

  @override
  Future<void> setAppLockType(String type) async {
    await _box.put('appLockType', type);
  }

  @override
  String? getAppLockPin() => _box.get('appLockPin') as String?;

  @override
  Future<void> setAppLockPin(String pin) async {
    await _box.put('appLockPin', pin);
  }

  @override
  int getLockTimeoutMinutes() =>
      _box.get('lockTimeoutMinutes', defaultValue: 1) as int;

  @override
  Future<void> setLockTimeoutMinutes(int minutes) async {
    await _box.put('lockTimeoutMinutes', minutes);
  }
}
