import 'package:arbor/api/responses/base_response.dart';
import 'package:arbor/core/constants/arbor_constants.dart';
import 'package:arbor/core/constants/hive_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsProvider extends ChangeNotifier {



  launchURL({required String url}) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  Future<BaseResponse> deleteArborData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(ArborConstants.IS_FIRST_TIME_USER_KEY);

      final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
      await secureStorage.deleteAll();

      await Hive.deleteBoxFromDisk(HiveConstants.walletBox);
      await Hive.deleteBoxFromDisk(HiveConstants.transactionsBox);

      return BaseResponse(
          success: true,
          error:
          "Your Arbor data was deleted. Please restart/reinstall the app.");
    } catch (error) {
      return BaseResponse(
          success: false,
          error: "We couldn't delete the data. Error: ${error.toString()}");
    }
  }
}