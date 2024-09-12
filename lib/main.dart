import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:arbor/core/providers/auth_provider.dart';
import 'package:arbor/core/constants/arbor_constants.dart';
import 'package:arbor/core/providers/restore_wallet_provider.dart';
import 'package:arbor/core/providers/send_crypto_provider.dart';
import 'package:arbor/core/providers/settings_provider.dart';
import 'package:arbor/core/utils/app_utils.dart';
import 'package:arbor/core/utils/local_storage_utils.dart';
import 'package:arbor/models/models.dart';
import 'package:arbor/views/screens/base/base_screen.dart';
import 'package:arbor/views/screens/no_encryption_available_sccreen.dart';
import 'package:arbor/views/screens/settings/unlock_with_pin_screen.dart';
import 'package:arbor/views/themes/arbor_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/hive_constants.dart';
import 'core/providers/create_wallet_provider.dart';
import 'models/blockchain.dart';
import 'models/transaction.dart';
import 'models/wallet.dart';
import 'views/screens/on_boarding/splash_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await customSharedPreference.init();

  try {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(
        key: HiveConstants.hiveEncryptionKeyKey);
    if (!containsEncryptionKey) {
      var newEncryptionKey = Hive.generateSecureKey();
      await secureStorage.write(
          key: HiveConstants.hiveEncryptionKeyKey,
          value: base64UrlEncode(newEncryptionKey));
      await secureStorage.write(
          key: HiveConstants.hiveEncryptionSchemaKey, value: "1");
    }
    await secureStorage.readAll();

    String? keyFromSecureStorage =
        await secureStorage.read(key: HiveConstants.hiveEncryptionKeyKey);
    if (keyFromSecureStorage != null && keyFromSecureStorage != '') {
      var encryptionKey = base64Url.decode(keyFromSecureStorage);

      _hiveAdaptersRegistration();
      // Opening the box
      try {
        await Hive.openBox(HiveConstants.walletBox,
            encryptionCipher: HiveAesCipher(encryptionKey));
        await Hive.openBox(HiveConstants.transactionsBox,
            encryptionCipher: HiveAesCipher(encryptionKey));
      } on Exception catch (error) {
        return runApp(
          MaterialApp(
            home: NoEncryptionAvailableScreen(
              message:
                  'We were unable to retrieve the encrypted keys to open your wallets. Please contact us.\n',
              errorString: 'Error: ${error.toString()}',
            ),
            debugShowCheckedModeBanner: false,
          ),
        );
      }

      runApp(MyApp());
    } else {
      return runApp(
        const MaterialApp(
          home: NoEncryptionAvailableScreen(
            message:
                'We were unable to retrieve the encrypted keys to open your wallets. Please contact us.',
            errorString: ' ',
          ),
          debugShowCheckedModeBanner: false,
        ),
      );
    }
  } catch (error) {
    return runApp(
      MaterialApp(
        home: NoEncryptionAvailableScreen(
          message:
              'We were unable to use the encrypted storage for your wallets. Please contact us.\n',
          errorString: 'Error: ${error.toString()}',
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void _hiveAdaptersRegistration() {
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(BlockchainAdapter());
  Hive.registerAdapter(TransactionsGroupAdapter());
  Hive.registerAdapter(TransactionAdapter());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamController<bool> _showLockScreenStream = StreamController();
  StreamSubscription? _showLockScreenSubs;
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  Future<bool> _isFirstTimeUser() async {
    bool _isFirstTime;
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime =
        (prefs.getBool(ArborConstants.IS_FIRST_TIME_USER_KEY) ?? true);
    return Future<bool>.value(_isFirstTime);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    _showLockScreenSubs = _showLockScreenStream.stream.listen((bool show) {
      if (mounted && show) {
        _showRequiredScreen();
      }
    });


  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    // Closes all Hive boxes
    Hive.close();
    WidgetsBinding.instance!.removeObserver(this);
    _showLockScreenSubs?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CreateWalletProvider()),
        ChangeNotifierProvider(create: (_) => RestoreWalletProvider()),
        ChangeNotifierProvider(create: (_) => SendCryptoProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: ScreenUtilInit(
        builder: () => MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Arbor',
            theme: ArborThemeData.lightTheme,
            debugShowCheckedModeBanner: false,
            home: FutureBuilder<bool>(
                future: _isFirstTimeUser(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    bool _isFirstTime = snapshot.data as bool;
                    if (_isFirstTime) {
                      return SplashScreen();
                    }else if(customSharedPreference.pinIsSet ||
                        customSharedPreference.biometricsIsSet){
                      return UnlockWithPinScreen(
                        fromRoot: true,
                        unlock: true,
                      );
                    }
                    else {
                      return const BaseScreen();
                    }
                  } else {
                    return Container(
                      color: ArborColors.green,
                    );
                  }
                }),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        _showLockScreenStream.add(true);
        debugPrint('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        debugPrint('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        debugPrint('appLifeCycleState detached');
        break;
    }
  }

  void _showRequiredScreen() async {
    bool isFirstTimer = await _isFirstTimeUser();

    if (authAction != null && authAction == AuthAction.SetUp) {
      _navigatorKey.currentState!.pushReplacement(
          new MaterialPageRoute(builder: (BuildContext context) {
            return BaseScreen();
          }));

    } else if (isFirstTimer) {
      _navigatorKey.currentState!.pushReplacement(
          new MaterialPageRoute(builder: (BuildContext context) {
        return SplashScreen();
      }));
    } else if (customSharedPreference.isAlreadyUnlocked == true &&
        Platform.isIOS) {
      _navigatorKey.currentState!.pushReplacement(
          new MaterialPageRoute(builder: (BuildContext context) {
        return BaseScreen();
      }));
      customSharedPreference.setIsAlreadyUnlocked(false);
    } else if (customSharedPreference.pinIsSet ||
        customSharedPreference.biometricsIsSet) {
      _navigatorKey.currentState!.pushReplacement(
          new MaterialPageRoute(builder: (BuildContext context) {
        return UnlockWithPinScreen(
          fromRoot: true,
          unlock: true,
        );
      }));
    } else {
      _navigatorKey.currentState!.pushReplacement(
          new MaterialPageRoute(builder: (BuildContext context) {
        return BaseScreen();
      }));
    }
  }
}
