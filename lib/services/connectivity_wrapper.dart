import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/config.dart';
import 'connectivity_service.dart'; // Import your service file

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _service = ConnectivityService();
  bool _isFirstLoad =
      true; // To prevent a popup showing as soon as the app opens

  @override
  void initState() {
    super.initState();
    _service.addListener(_updateUI);
  }

  @override
  void dispose() {
    _service.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    // Skip the very first notification if the app starts already connected
    if (_isFirstLoad) {
      _isFirstLoad = false;
      return;
    }

    final status = _service.status;
    bool isOffline = status == ConnectivityStatus.offline;

    // Use ScaffoldMessenger to show a popup that persists across pages
    Fluttertoast.showToast(
        msg: isOffline ? 'noInternet'.tr() : 'online'.tr(),
        backgroundColor: isOffline ? AppColors.red : AppColors.successColor);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(isOffline ? 'noInternet'.tr() : 'online'.tr()),
    //     backgroundColor: isOffline ? AppColors.red : AppColors.successColor,
    //     behavior: SnackBarBehavior.floating,
    //     duration: const Duration(seconds: 3),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<LanguageController>();

    return widget.child;
  }
}
