import 'dart:io';

import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:arbor/core/utils/app_utils.dart';
import 'package:arbor/core/utils/local_storage_utils.dart';
import 'package:arbor/views/widgets/dialogs/arbor_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

class SetBiometricsScreen extends StatefulWidget {
  const SetBiometricsScreen({Key? key}) : super(key: key);

  @override
  _SetBiometricsScreenState createState() => _SetBiometricsScreenState();
}

class _SetBiometricsScreenState extends State<SetBiometricsScreen> {
  List<BiometricType>? availableBiometrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => unlockWithBiometrics());
  }

  unlockWithBiometrics() async {
    var localAuth = LocalAuthentication();
    bool isSupported = await localAuth.isDeviceSupported();
    availableBiometrics = await localAuth.getAvailableBiometrics();
    debugPrint(
        "Device is supported? $isSupported Available biometrics-${availableBiometrics!.length}");

    if (Platform.isIOS) {
      if (availableBiometrics!.contains(BiometricType.face)) {
        // Face ID.
        debugPrint('has face ID!!!!');
        const iosStrings = const IOSAuthMessages(
            cancelButton: 'cancel',
            goToSettingsButton: 'settings',
            goToSettingsDescription: 'Please set up your Face ID.',
            lockOut: 'Please re-enable your Face ID');
        try {
          bool didAuthenticate = await localAuth.authenticate(
              localizedReason: 'Please authenticate with Face ID',
              useErrorDialogs: true,
              stickyAuth: true,
              biometricOnly: true,
              iOSAuthStrings: iosStrings);
          handleNavigationForBiometrics(didAuthenticate);
        } on PlatformException catch (e) {
          int count = 0;
          showInfoDialog(context,
              title: "ERROR", description: e.message.toString(), onPressed: () {
            Navigator.of(
              context,
            ).popUntil((_) => count++ >= 2);
          });
        } on Exception catch (e) {
          debugPrint("${e.toString()}");
          AppUtils.showSnackBar(
              context, "${e.toString()}", ArborColors.errorRed);
        }
      } else if (availableBiometrics!.contains(BiometricType.fingerprint)) {
        // Face ID.
        debugPrint('has face ID!!!!');
        const iosStrings = const IOSAuthMessages(
            cancelButton: 'cancel',
            goToSettingsButton: 'settings',
            goToSettingsDescription: 'Please set up your fingerprint.',
            lockOut: 'Please re-enable your fingerprint ID');
        try {
          bool didAuthenticate = await localAuth.authenticate(
              localizedReason: 'Please authenticate with fingerprint',
              useErrorDialogs: true,
              stickyAuth: true,
              biometricOnly: true,
              iOSAuthStrings: iosStrings);

          handleNavigationForBiometrics(didAuthenticate);
        } on PlatformException catch (e) {
          int count = 0;
          showInfoDialog(context,
              title: "ERROR", description: e.message.toString(), onPressed: () {
            Navigator.of(
              context,
            ).popUntil((_) => count++ >= 2);
          });
        } on Exception catch (e) {
          debugPrint("${e.toString()}");
          AppUtils.showSnackBar(
              context, "${e.toString()}", ArborColors.errorRed);
        }
      }
    } else if (Platform.isAndroid) {
      if (availableBiometrics!.contains(BiometricType.fingerprint)) {
        // Touch ID.

        const androidStrings = const AndroidAuthMessages(
            cancelButton: 'cancel',
            goToSettingsButton: 'settings',
            goToSettingsDescription: 'Please set up your fingerprint ID.');
        try {
          bool didAuthenticate = await localAuth.authenticate(
            localizedReason: 'Please authenticate with fingerprint',
            useErrorDialogs: true,
            biometricOnly: true,
            stickyAuth: true,
            androidAuthStrings: androidStrings,
          );
          handleNavigationForBiometrics(didAuthenticate);
        } on PlatformException catch (e) {
          int count = 0;
          showInfoDialog(context,
              title: "ERROR", description: e.message.toString(), onPressed: () {
            Navigator.of(
              context,
            ).popUntil((_) => count++ >= 2);
          });
        } on Exception catch (e) {
          debugPrint("${e.toString()}");
          AppUtils.showSnackBar(
              context, "${e.toString()}", ArborColors.errorRed);
        }
      }
    }
  }

  handleNavigationForBiometrics(bool result) {
    int count = 0;
    if (result) {
      customSharedPreference.setUseBiometrics(true);
      Navigator.pop(context, true);
    } else {
      showInfoDialog(context,
          title: "Authentication Failed",
          description:
              "This wallet is secured. The biometric used is incorrect",
          onPressed: () {
        Navigator.of(
          context,
        ).popUntil((_) => count++ >= 2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ArborColors.green,
      child: SafeArea(
          child: Scaffold(
        backgroundColor: ArborColors.green,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Set Biometrics',
            style: TextStyle(
              color: ArborColors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: Icon(
              Icons.arrow_back,
              color: ArborColors.white,
            ),
          ),
          backgroundColor: ArborColors.green,
        ),
        body: Container(),
      )),
    );
  }

  void showInfoDialog(BuildContext context,
      {required String title,
      required String description,
      required VoidCallback? onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ArborInfoDialog(
          title: title,
          description: description,
          onPressed: onPressed,
        );
      },
    );
  }
}
