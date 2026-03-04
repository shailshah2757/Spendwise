import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final auth = ref.read(authServiceProvider);
  return auth.isBiometricAvailable();
});
