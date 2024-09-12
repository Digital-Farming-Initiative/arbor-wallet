import 'package:arbor/core/constants/arbor_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomSharedPreference {
  static SharedPreferences? _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  bool get hasBiometrics =>
      _sharedPrefs!.getBool(ArborConstants.HAS_BIOMETRICS_KEY) ?? false;
  bool get pinIsSet =>
      _sharedPrefs!.getBool(ArborConstants.IS_PIN_ENABLED_KEY) ?? false;
  bool get biometricsIsSet =>
      _sharedPrefs!.getBool(ArborConstants.IS_BIOMETRICS_ENABLED_KEY) ?? false;

  String get pin => _sharedPrefs!.getString(ArborConstants.PIN_KEY) ?? "";

  bool get isAlreadyUnlocked =>
      _sharedPrefs!.getBool(ArborConstants.IS_ALREADY_UNLOCKED_KEY) ?? false;

  setPin(String pin) {
    _sharedPrefs!.setString(ArborConstants.PIN_KEY, pin);
  }

  setHasBiometrics(bool value) {
    _sharedPrefs!.setBool(ArborConstants.HAS_BIOMETRICS_KEY, value);
  }

  setUsePin(bool value) {
    _sharedPrefs!.setBool(ArborConstants.IS_PIN_ENABLED_KEY, value);
  }

  setUseBiometrics(bool value) {
    _sharedPrefs!.setBool(ArborConstants.IS_BIOMETRICS_ENABLED_KEY, value);
  }

  setIsAlreadyUnlocked(bool value) {
    _sharedPrefs!.setBool(ArborConstants.IS_ALREADY_UNLOCKED_KEY, value);
  }
}

final customSharedPreference = CustomSharedPreference();
