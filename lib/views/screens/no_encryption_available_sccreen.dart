import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:arbor/core/constants/asset_paths.dart';
import 'package:arbor/core/constants/hive_constants.dart';
import 'package:arbor/views/widgets/arbor_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arbor/constants.dart';

class NoEncryptionAvailableScreen extends StatelessWidget {
  const NoEncryptionAvailableScreen({Key? key, required this.message, required this.errorString}) : super(key: key);
  final String message;
  final String errorString;
  static const VIEW_PADDING = 40.0;

  void _launchURL({required String url}) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: ArborColors.green,
          body: SafeArea(
            top: true,
            bottom: true,
            left: true,
            right: true,
            child: Padding(
                padding: EdgeInsets.fromLTRB(VIEW_PADDING, 0.0, VIEW_PADDING, 0.0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Center(
                          child: Image.asset(
                            AssetPaths.logo,
                          ),
                        ),
                      ),
                      Spacer(flex: 2,),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Flexible(
                            child: InkWell(
                              child: Text(
                                errorString,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: errorString));
                              },
                            )
                          ),
                          InkWell(
                            child: Icon(
                                Icons.copy,
                            ),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: errorString));
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: ArborButton(
                              onPressed: () {
                                deleteArborData(context);
                              },
                              title: 'Erase Arbor Data',
                              backgroundColor: ArborColors.deepGreen,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: ArborButton(
                              onPressed: () {
                                _launchURL(url: ArborConstants.baseWebsiteURL);
                              },
                              title: 'Contact Us',
                              backgroundColor: ArborColors.deepGreen,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40,),
                    ],
                  ),
                )
            ),
          )
      ),
    );
  }

  void deleteArborData(BuildContext context) async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Wallet",
            style: TextStyle(fontSize: 14, color: ArborColors.black),),
          content: Text(
            "You cannot undo this action. Do you want to proceed to all Arbor data?",
            style: TextStyle(fontSize: 12, color: ArborColors.black),),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text(
                "Yes", style: TextStyle(color: ArborColors.errorRed),),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
    if (result == true) {
      attemptToDeleteArborData(context);
    }
  }

  void attemptToDeleteArborData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(ArborConstants.IS_FIRST_TIME_USER_KEY);

      final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
      await secureStorage.deleteAll();

      await Hive.deleteBoxFromDisk(HiveConstants.walletBox);
      await Hive.deleteBoxFromDisk(HiveConstants.transactionsBox);

      _showDeleteArborDataSuccess(context);
    } catch (error) {
      print('Error: ${error.toString()}');
      _showDeleteArborDataFailed(context, error.toString());
    }
  }

  void _showDeleteArborDataSuccess(BuildContext context) async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Arbor Data Deleted",
            style: TextStyle(fontSize: 14, color: ArborColors.black),),
          content: Text(
            "Your Arbor data was deleted. Please restart/reinstall the app.",
            style: TextStyle(fontSize: 12, color: ArborColors.black),),
          actions: [
          ],
        );
      },
    );
  }
  void _showDeleteArborDataFailed(BuildContext context, String errorString) async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erase Arbor Data Failed",
            style: TextStyle(fontSize: 14, color: ArborColors.black),),
          content: Text(
            "We couldn't delete the data. Error: ${errorString}",
            style: TextStyle(fontSize: 12, color: ArborColors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }
}