import 'dart:io';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:arbor/core/enums/status.dart';
import 'package:arbor/core/providers/auth_provider.dart';
import 'package:arbor/core/utils/app_utils.dart';
import 'package:arbor/core/utils/local_storage_util.dart';
import 'package:arbor/core/utils/navigation_utils.dart';
import 'package:arbor/views/screens/base/base_screen.dart';
import 'package:arbor/views/widgets/keypad/arbor_keypad.dart';
import 'package:arbor/views/widgets/pin/pin_indicator.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnlockWithPinScreen extends StatefulWidget {
  final bool unlock;
  final bool fromRoot;

  const UnlockWithPinScreen({Key? key, this.unlock: true, this.fromRoot: false})
      : super(key: key);

  @override
  _UnlockWithPinScreenState createState() => _UnlockWithPinScreenState();
}

class _UnlockWithPinScreenState extends State<UnlockWithPinScreen> {
  List<BiometricType>? availableBiometrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => unlockWithBiometrics());
  }

  unlockWithBiometrics() async {
    var enabledBiometrics = customSharedPreference.biometricsIsSet;
    if (enabledBiometrics) {
      var localAuth = LocalAuthentication();
      availableBiometrics = await localAuth.getAvailableBiometrics();

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
                iOSAuthStrings: iosStrings);
            if (didAuthenticate) {
              NavigationUtils.pushReplacement(context, BaseScreen());
            }
          } catch (e) {
            AppUtils.showSnackBar(context,
                "Unable to authenticate with face ID", ArborColors.errorRed);
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
                iOSAuthStrings: iosStrings);
            if (didAuthenticate) {
              NavigationUtils.pushReplacement(context, BaseScreen());
            }
          } catch (e) {
            AppUtils.showSnackBar(
                context,
                "Unable to authenticate with fingerprint",
                ArborColors.errorRed);
          }
        }
      } else if (Platform.isAndroid) {
        if (availableBiometrics!.contains(BiometricType.fingerprint)) {
          // Touch ID.
          debugPrint('has touch ID!!!!');
          const androidStrings = const AndroidAuthMessages(
              cancelButton: 'cancel',
              goToSettingsButton: 'settings',
              goToSettingsDescription: 'Please set up your fingerprint ID.');
          try {
            bool didAuthenticate = await localAuth.authenticate(
              localizedReason: 'Please authenticate with fingerprint',
              androidAuthStrings: androidStrings,
            );
            if (didAuthenticate) {
              NavigationUtils.pushReplacement(context, BaseScreen());
            }
          } catch (e) {
            AppUtils.showSnackBar(
                context,
                "Unable to authenticate with fingerprint",
                ArborColors.errorRed);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (_, model, __) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (model.setPinStatus == Status.SUCCESS) {
          if (model.unlock == true) {
            NavigationUtils.pushReplacement(context, BaseScreen());
          } else {
            Navigator.pop(context, true);
          }

          model.clearStatus();
        }
      });
      return Container(
        color: ArborColors.green,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: ArborColors.green,
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              leading: widget.fromRoot
                  ? null
                  : IconButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: ArborColors.white,
                      ),
                    ),
              title: Text(
                'Unlock With Pin',
                style: TextStyle(
                  color: ArborColors.white,
                ),
              ),
              backgroundColor: ArborColors.green,
            ),
            body: Container(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Enter your ${model.pinLength} digit",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: ArborColors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        ShakeAnimatedWidget(
                          child: PinIndicator(
                            currentPinLength: model.currentPin.length,
                            totalPinLength: model.pinLength,
                          ),
                          enabled: model.invalidPin,
                          duration: Duration(milliseconds: 200),
                          shakeAngle: Rotation.deg(z: 10.0),
                          curve: Curves.linear,
                        )
                      ],
                    ),
                  ),
                  ArborKeyPad(
                    size: ArborKeyPadSize.compact,
                    onKeyPressed: (key) => widget.unlock
                        ? model.unlockWithPin(key)
                        : model.disablePin(key),
                    clearIcon: Icon(
                      Icons.arrow_back,
                      size: 14.0,
                      color: ArborColors.white,
                    ),
                    onBackKeyPressed: () => model.clear(),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
