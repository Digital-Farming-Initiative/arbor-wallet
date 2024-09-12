import 'dart:io';
import 'package:arbor/api/responses.dart';
import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:arbor/core/constants/arbor_constants.dart';
import 'package:arbor/core/constants/asset_paths.dart';
import 'package:arbor/core/providers/auth_provider.dart';
import 'package:arbor/core/providers/settings_provider.dart';
import 'package:arbor/core/utils/app_utils.dart';
import 'package:arbor/core/utils/local_storage_utils.dart';
import 'package:arbor/views/screens/settings/set_pin_screen.dart';
import 'package:arbor/views/screens/settings/unlock_with_pin_screen.dart';
import 'package:arbor/views/widgets/arbor_switch.dart';
import 'package:arbor/views/widgets/dialogs/arbor_alert_dialog.dart';
import 'package:arbor/views/widgets/dialogs/arbor_info_dialog.dart';
import 'package:arbor/views/widgets/tiles/settings_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? packageInfo;
  String appVersion = "";

  @override
  void initState() {
    AuthProvider();
    _getAppDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, model, __) {
      return Container(
        height: MediaQuery.of(context).size.height,
        color: ArborColors.green,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: ArborColors.green,
            body: Container(
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.symmetric(vertical: 16),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "General",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: ArborColors.white,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        SettingsTile(
                          title: "Visit DFI Discord Channel",
                          assetPath: AssetPaths.discord,
                          onPressed: () => model.launchURL(
                              url: ArborConstants.discordChannelURL),
                        ),
                        SettingsTile(
                          title: "View Privacy Policy",
                          assetPath: AssetPaths.privacyPolicy,
                          onPressed: () => model.launchURL(
                              url: ArborConstants.websitePrivacyURL),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Security",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: ArborColors.white,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        SettingsTile(
                          title: "Unlock with PIN",
                          assetPath: AssetPaths.padlock,
                          trailing: ArborSwitch(
                            state: customSharedPreference.pinIsSet,
                            onChanged: (v) => toggleUnlockWithPIN(),
                          ),
                          onPressed: () => toggleUnlockWithPIN(),
                        ),
                        customSharedPreference.hasBiometrics
                            ? SettingsTile(
                                title: "Unlock with biometrics",
                                assetPath: Platform.isIOS
                                    ? AssetPaths.faceId
                                    : AssetPaths.fingerprint,
                                trailing: ArborSwitch(
                                  state: customSharedPreference.biometricsIsSet,
                                  onChanged: (_) =>
                                      toggleUnlockWithBiometrics(),
                                ),
                                onPressed: () => toggleUnlockWithBiometrics(),
                              )
                            : Container(),
                        SizedBox(height: 10),
                        Text(
                          "Arbor Data",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: ArborColors.white,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        SettingsTile(
                          title: "Delete Arbor Data",
                          assetPath: AssetPaths.delete,
                          onPressed: () async {
                            await deleteData(model);
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'v$appVersion',
                    style: TextStyle(
                      color: ArborColors.white,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  toggleUnlockWithPIN() async {
    var result;
    bool isSet = customSharedPreference.pinIsSet;
    if (isSet == false) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetPinScreen(),
        ),
      );
    } else {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnlockWithPinScreen(
            unlock: false,
          ),
        ),
      );
    }
    if (result == true) {
      setState(() {});
    }
  }

  toggleUnlockWithBiometrics() async {
    bool pinIsSet = customSharedPreference.pinIsSet;
    bool biometricIsSet = customSharedPreference.biometricsIsSet;

    if (pinIsSet) {
      if (biometricIsSet == false) {
        authAction=AuthAction.SetUp;
        var localAuth = LocalAuthentication();
        bool isSupported = await localAuth.isDeviceSupported();
        List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
        if(isSupported && (availableBiometrics.contains(BiometricType.face) ||availableBiometrics.contains(BiometricType.fingerprint)) ){
          customSharedPreference.setUseBiometrics(true);
          setState(() {});
        }else if (isSupported==false&& (availableBiometrics.contains(BiometricType.face) ||availableBiometrics.contains(BiometricType.fingerprint))){
          showInfoDialog(context,
              title: "Error",
              description: "You have not enrolled biometrics",
              onPressed: null);
        }else{
          showInfoDialog(context,
              title: "Error",
              description: "Your device does not support biometrics",
              onPressed: null);
        }
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnlockWithPinScreen(
              unlock: false,
            ),
          ),
        );
        setState(() {});
      }
    } else {
      showInfoDialog(context,
          title: "Error",
          description: "Please enable 'Unlock with PIN' first",
          onPressed: null);
    }
  }

  void _getAppDetails() async {
    packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo!.version;
  }

  deleteData(SettingsProvider model) async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ArborAlertDialog(
          title: "Delete Your Data",
          subTitle:
              "You cannot undo this action. Do you want to proceed to delete all Arbor data?",
          onCancelPressed: () => Navigator.pop(context, false),
          onYesPressed: () => Navigator.pop(context, true),
        );
      },
    );
    if (result == true) {
      BaseResponse response = await model.deleteArborData();
      if (response.success == true) {
        showInfoDialog(context,
            title: "Arbor Data Deleted",
            description: "${response.error}", onPressed: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        });
      } else {
        showInfoDialog(context,
            title: "Erase Arbor Data Failed",
            description: "${response.error}",
            onPressed: null);
      }
    }
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
