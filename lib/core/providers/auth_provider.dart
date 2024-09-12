import 'package:arbor/core/enums/status.dart';
import 'package:arbor/core/utils/local_storage_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

enum AuthAction{
  Resume,
  SetUp,
  Unlock,
}

class AuthProvider extends ChangeNotifier {
  final LocalAuthentication localAuthentication = LocalAuthentication();

  String _firstPin = "";
  String _currentPin = "";
  int _currentStep = 1;
  bool _invalidPin = false;
  final int _pinLength = 6;

  bool unlock = true;

  Status setPinStatus = Status.IDLE;

  get firstPin => _firstPin;
  get currentPin => _currentPin;
  get currentStep => _currentStep;
  get invalidPin => _invalidPin;
  get pinLength => _pinLength;


  AuthProvider(){
    hasBiometrics();
  }

  ///Biometrics
  //Check if device support biometrics
   hasBiometrics() async {
    bool deviceHasBiometrics = await localAuthentication.canCheckBiometrics;
    customSharedPreference.setHasBiometrics(deviceHasBiometrics);
    //return deviceHasBiometrics;
  }

  //Check the available biometric support
  Future<BiometricType> biometricType() async {
    List<BiometricType> availableBiometrics =
        await localAuthentication.getAvailableBiometrics();
    if (availableBiometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else {
      return BiometricType.fingerprint;
    }
  }

  ///PIN
  void clear() {
    if (_currentPin.length > 0) {
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      notifyListeners();
    }
  }

  unlockWithPin(String key) {
    if (_currentPin.length <= _pinLength) {
      _currentPin = _currentPin + key;
      notifyListeners();
    }
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (_currentPin.length == _pinLength) {
          unlock = true;
          String _savedPin = customSharedPreference.pin;

          if (_currentPin != _savedPin) {
            _invalidPin = true;
            notifyListeners();
            resetInvalidPin();
          } else {
            _currentPin = "";
            setPinStatus = Status.SUCCESS;
            notifyListeners();
          }
        }
      },
    );
  }

  disablePin(String key) {
    if (_currentPin.length <= _pinLength) {
      _currentPin = _currentPin + key;
      notifyListeners();
    }
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (_currentPin.length == _pinLength) {
          unlock = false;
          String _savedPin = customSharedPreference.pin;

          if (_currentPin != _savedPin) {
            _invalidPin = true;
            notifyListeners();
            resetInvalidPin();
          } else {
            customSharedPreference.setUsePin(false);
            customSharedPreference.setUseBiometrics(false);
            _currentPin = "";
            setPinStatus = Status.SUCCESS;
            notifyListeners();
          }
        }
      },
    );
  }

  void handleKeyPressed(String key) {
    if (_currentPin.length <= _pinLength) {
      _currentPin = _currentPin + key;
      notifyListeners();
    }
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (_currentPin.length == _pinLength) {
          if (_currentStep == 1) {
            _firstPin = currentPin;
            _currentStep = 2;
            _currentPin = "";
            notifyListeners();
            return;
          }

          if (_currentStep == 2) {
            if (_firstPin != _currentPin) {
              _invalidPin = true;
              notifyListeners();
              resetInvalidPin();
            } else {
              customSharedPreference.setPin(_currentPin);
              customSharedPreference.setUsePin(true);
              _currentPin = "";
              setPinStatus = Status.SUCCESS;
              notifyListeners();
            }
          }
        }
      },
    );
  }

  void goBack() async {
    _currentStep = 1;
    _currentPin = "";
    notifyListeners();
  }

  void resetInvalidPin() {
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        _invalidPin = false;
        _currentPin = "";
        notifyListeners();
      },
    );
  }

  clearStatus() {
    setPinStatus = Status.IDLE;
  }
}
