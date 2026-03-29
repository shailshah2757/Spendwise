import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String _pin = '';
  String? _firstPin;
  String? _error;
  bool get _isConfirming => _firstPin != null;

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == 4) {
      _handleComplete();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _handleComplete() async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
      });
    } else {
      if (_pin == _firstPin) {
        final repo = ref.read(settingsRepositoryProvider);
        await repo.setAppLockPin(_pin);
        await repo.setAppLockType('pin');
        await repo.setAppLockEnabled(true);
        ref.read(appLockEnabledProvider.notifier).state = true;
        ref.read(appLockTypeProvider.notifier).state = 'pin';
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _pin = '';
          _firstPin = null;
          _error = 'PINs don\'t match. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set PIN'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Create a 4-digit PIN',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConfirming
                  ? 'Enter your PIN again to confirm'
                  : 'This PIN will be used to lock the app',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? cs.primary : Colors.transparent,
                    border: Border.all(
                      color: filled ? cs.primary : cs.outlineVariant,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
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
            _buildNumberPad(cs),
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
