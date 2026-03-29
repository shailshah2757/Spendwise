abstract class SettingsRepository {
  String getCurrency();
  String getCurrencySymbol();
  Future<void> setCurrency(String code, String symbol);
  bool isFirstLaunch();
  Future<void> setFirstLaunchDone();
  double getMonthlyBudget();
  Future<void> setMonthlyBudget(double amount);
  bool isAppLockEnabled();
  Future<void> setAppLockEnabled(bool enabled);
  String getAppLockType(); // 'pin' or 'biometric'
  Future<void> setAppLockType(String type);
  String? getAppLockPin();
  Future<void> setAppLockPin(String pin);
  int getLockTimeoutMinutes();
  Future<void> setLockTimeoutMinutes(int minutes);
}
