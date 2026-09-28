import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../custom_page_route.dart';
import '../../data/local/local.dart';
import '../../helper/general_helper.dart';
import '../../helper/helper.dart';
import 'home_view.dart';
import 'login_view.dart';
import 'on_boarding_view.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  bool firstInstall = false;

  @override
  void initState() {
    super.initState();

    startPage();
  }

  startPage() async {
    final installDate = await GeneralHelper.getInstallDate();

    if (installDate == null) {
      firstInstall = true;
      await GeneralHelper.saveFirstInstallDate();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        NoAnimationPageRoute(builder: (context) => const OnBoardingView()),
        (route) => false,
      );
    } else {
      firstInstall = false;

      // getLoginDBItem();
      if (!context.mounted) return;
      await initializeAppSession(context);
    }
  }

  Future<void> initializeAppSession(BuildContext context) async {
    // Retrieve bearer token from secure storage
    final token = await Storage().getToken();

    if (token == null || token.isEmpty) {
      if (!context.mounted) return;
      // No token found -> Navigate to Login
      navigateToLogin(context);
      return;
    }

    // Assign to runtime storage
    Storage().token = token;

    // Load non-sensitive UI details (location, user name) from SQLite
    final loginDetails = await DBMasterLoginList().getAllLoginList();

    if (loginDetails != null && loginDetails.isNotEmpty) {
      final user = loginDetails.first;
      Storage().loginId = user['login_id'] ?? 0;
      Storage().loginName = user['login_username'] ?? '';
      Storage().selectedLocationID = user['location_id'] ?? 0;
      Storage().selectedLocation = user['location_name']?.toString() ?? '';
      Storage().trayWeight = user['tray_weight'] ?? 0.0;

      // // (Optional) Validate token with server before landing on main screen
      // final isSessionValid = await ApiGlobalHelper().validateToken(token);
      // if (isSessionValid) {
      if (!context.mounted) return;
      navigateToHomepage(context);
      // } else {
      // Server returned 401 or token expired -> clear token and force re-login
      // await Storage().deleteToken();
      // navigateToLogin(context);
      // }
    } else {
      if (!context.mounted) return;
      navigateToLogin(context);
    }
  }

  navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  navigateToHomepage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const HomeView()),
      (route) => false,
    );
  }

  // // Function to get Login in DB
  // getLoginDBItem() async {
  //   DBMasterLoginList().getAllLoginList().then((value) async {
  //     // Check if got login ID in DB
  //     if (value != null) {
  //       // print('VALUE DB LOGIN: $value');
  //       // If have value
  //       // Save in storage
  //       Storage().loginId = value[0]['login_id'];
  //       Storage().loginName = value[0]['login_username'];
  //       Storage().token = value[0]['login_token'];
  //       Storage().selectedLocationID = value[0]['location_id'] ?? 0;
  //       Storage().selectedLocation = value[0]['location_name'].toString();
  //       Storage().trayWeight = value[0]['tray_weight'] ?? 0.0;

  //       // Navigate
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomeView()),
  //         (route) => false,
  //       );
  //     } else {
  //       // If no value in Login DB
  //       await DBMasterLoginList().deleteAllLoginList();
  //       // ignore: use_build_context_synchronously
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         NoAnimationPageRoute(builder: (context) => const LoginView()),
  //         (route) => false,
  //       );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
