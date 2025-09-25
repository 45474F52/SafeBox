import 'package:local_auth/local_auth.dart';

import '../../models/exceptions/biometrics_exception.dart';

class BiometricAuth {
  final _auth = LocalAuthentication();

  Future<bool> isBiometricsAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();
    final isLocked = (await _auth.getAvailableBiometrics()).isEmpty;

    if (!canCheck) {
      throw BiometricsException(
        'Устройство не поддерживает проверку биометрии',
      );
    }

    if (!isSupported) {
      throw BiometricsException(
        'Устройство не поддерживает переключение на учётные данные',
      );
    }

    if (isLocked) {
      throw BiometricsException(
        'Проверка биометрии не настроена на устройстве',
      );
    }

    return true;
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Вход в SafeBox',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          sensitiveTransaction: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      throw BiometricsException(e.toString());
    }
  }
}
