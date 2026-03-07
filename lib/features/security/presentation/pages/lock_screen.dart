import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/security_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  String? _error;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
  }

  Future<void> _tryBiometric() async {
    final lockType = ref.read(appLockTypeProvider);
    if (lockType != 'biometric') return;

    setState(() => _authenticating = true);
    final auth = ref.read(authServiceProvider);
    final success = await auth.authenticateWithBiometrics();
    if (success) {
      widget.onUnlocked();
    } else {
      setState(() {
        _authenticating = false;
        _error = 'Authentication failed. Try again.';
      });
    }
  }

  void _onDigit(String digit) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _error = null;
    });
    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _error = null;
    });
  }

  void _verifyPin() {
    final repo = ref.read(settingsRepositoryProvider);
    final storedPin = repo.getAppLockPin();
    final auth = ref.read(authServiceProvider);

    if (storedPin != null && auth.validatePin(_enteredPin, storedPin)) {
      widget.onUnlocked();
    } else {
      setState(() {
        _enteredPin = '';
        _error = 'Incorrect PIN. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockType = ref.watch(appLockTypeProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary, cs.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.lock_outline,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              lockType == 'biometric' ? 'Authenticate' : 'Enter PIN',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock to access your expenses',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            if (lockType == 'biometric' && _authenticating)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (lockType == 'biometric' && !_authenticating) ...[
              ElevatedButton.icon(
                onPressed: _tryBiometric,
                icon: const Icon(Icons.fingerprint, size: 24),
                label: const Text('Retry Biometric'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _enteredPin.length;
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          filled ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? cs.primary
                            : cs.outlineVariant,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: cs.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const Spacer(),

            if (lockType == 'pin') _buildNumberPad(cs),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', 'back'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) {
                  if (key.isEmpty) {
                    return const SizedBox(width: 72, height: 60);
                  }
                  if (key == 'back') {
                    return _PadKey(
                      onTap: _onBackspace,
                      child: Icon(Icons.backspace_outlined,
                          size: 22, color: cs.onSurface),
                    );
                  }
                  return _PadKey(
                    onTap: () => _onDigit(key),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PadKey({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 60,
        child: Center(child: child),
      ),
    );
  }
}
