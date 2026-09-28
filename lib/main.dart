import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/config.dart';
import 'config/environment.dart';
import 'helper/helper.dart';
import 'presentation/features/startup_view.dart';
import 'services/services.dart';

RemoteMessage? globalInitialMessage;

void main() async {
  // Initialize current language
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EnvironmentConfig.init();

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('lang') ?? 'en';

  if (EnvironmentConfig.firebaseOptions != null) {
    await Firebase.initializeApp(
      options: EnvironmentConfig.firebaseOptions!,
    );

    NotificationService.instance.initialize();
    NotificationService.instance.getDeviceToken();

    globalInitialMessage = await FirebaseMessaging.instance.getInitialMessage();
    debugPrint("Firebase Initialized");
  } else {
    debugPrint("Firebase Skipped (No config for this flavor)");
  }

  // AppConfig.initialize();
  // await ConnectivityService().initialize();
  // await CleanDBHelper().checkAppVersionAndClearData();

  await getInfoAppAndData();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.white, // Top bar
      statusBarIconBrightness: Brightness.dark, // Dark icons
      systemNavigationBarColor: AppColors.black, // Bottom bar
      systemNavigationBarIconBrightness: Brightness.light, // Dark icons
    ),
  );

  // 2. Set the preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    // The controller for language. Set it to main to run on all page
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => LanguageController()),
        // ChangeNotifierProvider(create: (context) => WeightProvider()),
        // ChangeNotifierProvider(create: (_) => ConnectivityService()),
        // Connect Bluetooth
        Provider<BluetoothHelper>(
          create: (_) => BluetoothHelper(FlutterReactiveBle()),
          dispose: (_, bluetoothState) => bluetoothState.dispose(),
        ),
      ],
      // Enable localization based on language selected
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ms', 'MY')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en', 'US'),
        startLocale: savedLang == 'ms'
            ? const Locale('ms', 'MY')
            : const Locale('en', 'US'),
        child: const MyApp(),
      ),
    ),
  );
}

// Get information detail
getInfoAppAndData() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  String buildVersionNum = '$version+$buildNumber';
  Storage().packageVersion = buildVersionNum;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Check which language is selected
    // if (context.locale.toString().contains('en')) {
    //   LanguageController().changeLanguage('en');
    // } else if (context.locale.toString().contains('ms')) {
    //   LanguageController().changeLanguage('ms');
    // }

    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: (context, child) {
        return ConnectivityWrapper(child: child!);
      },
      home: const StartupView(),
    );
  }
}
