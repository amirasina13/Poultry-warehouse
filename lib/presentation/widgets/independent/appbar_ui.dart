import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../../config/config.dart';
import '../../../custom_page_route.dart';
import '../../../data/local/local.dart';
import '../../../helper/helper.dart';
import '../../features/home_view.dart';
import '../../features/login_view.dart';
import '../data_driven/data_driven.dart';
import 'independent.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onHomePressed;
  // final BluetoothHelper? bluetoothState;
  final VoidCallback? onTapOpenDrawer;
  final bool showLogout;
  final bool bluetoothTap;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle = '',
    this.onBackPressed,
    this.onHomePressed,
    // this.bluetoothState,
    this.onTapOpenDrawer,
    this.showLogout = false,
    this.bluetoothTap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    final bluetoothState = Provider.of<BluetoothHelper>(context);
    // context.watch<LanguageController>();

    return SafeArea(
        child: AppBar(
      elevation: 2,
      shadowColor: AppColors.borderColorGrey.withOpacity(0.2),
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      centerTitle: true,
      title: subtitle.isEmpty
          ? Text(
              title,
              style: TextStyle(
                fontSize: AppSettings.fontSizeAppbar,
                fontFamily: AppSettings.fontFamilyMain,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSettings.fontSizeAppbar,
                    fontFamily: AppSettings.fontFamilyMain,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppSettings.fontSizeTitle,
                    fontFamily: AppSettings.fontFamilyMain,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
      // leading: Visibility(
      //   visible: onBackPressed != null,
      //   child: IconButton(
      //     icon: Icon(Icons.arrow_back, color: AppColors.black),
      //     onPressed: onBackPressed,
      //   ),
      // ),
      // leading: Builder(
      //   builder: (context) => IconButton(
      //     icon: Icon(Icons.menu, color: AppColors.black),
      //     onPressed: () {
      //       Scaffold.of(context).openDrawer();
      //     },
      //   ),
      // ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(12),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(),
        ),
      ),
      actions: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: bluetoothState.connected,
                  builder: (context, isConnected, _) {
                    return Material(
                      color: AppColors.transparent.withOpacity(0),
                      child: GestureDetector(
                        //borderRadius: BorderRadius.circular(8),
                        onTap: bluetoothTap
                            ? () {
                                Navigator.push(
                                  context,
                                  NoAnimationPageRoute(
                                    builder: (context) =>
                                        BluetoothWeightPage(bluetoothState),
                                  ),
                                );
                              }
                            : () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isConnected
                                  ? AppColors.addBtn
                                  : AppColors.deleteBtn),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/bluetooth.svg',
                                width: width * 0.015,
                                height: height * 0.015,
                                colorFilter: ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                              Text(
                                  isConnected
                                      ? "connected".tr()
                                      : "disconnected".tr(),
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: AppSettings.fontSizeSubtitle,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                if (showLogout) ...[
                  Material(
                      color: AppColors.transparent.withOpacity(0),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            logoutConfirmationDialog(context);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/logout.svg',
                            width: orientation == Orientation.portrait
                                ? width * 0.03
                                : width * 0.05,
                            height: orientation == Orientation.portrait
                                ? height * 0.03
                                : height * 0.05,
                          )))
                ] else ...[
                  Material(
                      color: AppColors.transparent.withOpacity(0),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            navigateToHome(context);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/house.svg',
                            width: orientation == Orientation.portrait
                                ? width * 0.03
                                : width * 0.05,
                            height: orientation == Orientation.portrait
                                ? height * 0.03
                                : height * 0.05,
                          )))
                ]
              ],
            ))
      ],
    ));
  }

  // Widget openDrawer(BuildContext context) {
  //   final size = MediaQuery.of(context).size;

  //   if (onTapOpenDrawer == null) {
  //     return const SizedBox.shrink();
  //   }

  //   return Container(
  //       margin: const EdgeInsets.only(right: 10),
  //       child: GestureDetector(
  //         onTap: onTapOpenDrawer,
  //         child: SvgPicture.asset(
  //           'assets/icons/circle-info.svg',
  //           width: size.width * 0.02,
  //           height: size.height * 0.02,
  //         ),
  //       ));
  // }

  Future<void> logoutConfirmationDialog(BuildContext context) async {
    // final device = OrientationHelper(context);
    await OptionDialog.show(context,
            title: "logoutTitle".tr(),
            message: Text(
              "logoutMsg".tr(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
            typeDialog: 'delete',
            // dialogHeight: device.height() * 0.2,
            verticalPadding: 10)
        .then((value) async {
      if (value == true) {
        userLogout(context);
      }
    });
  }

  void navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        NoAnimationPageRoute(builder: (context) => const HomeView()),
        (route) => false);
  }

  Future<void> userLogout(BuildContext context) async {
    try {
      await DBMasterLoginList().deleteAllLoginList();

      // Clear all stored data
      final storage = Storage();
      storage.loginName = '';
      storage.loginPwd = ''; // Added missing reset
      storage.token = '';
      storage.selectedLocation = '';
      storage.selectedLocationID = 0;
      storage.transactionNo = '';
      storage.trayWeight = 0.00;
      storage.jobID = 0;
      storage.selectedPickingID = 0;
      storage.goodsIssues = 0;
      storage.goodsReceive = 0;
      storage.plStatusState = '';

      await DBJobData().deleteAllAddJob();
      await DBGoodsData().deleteAllGoodsData();

      if (!context.mounted) return;
      showSuccessToast('logoutSuccess'.tr(), context);
      // Navigate
      Navigator.pushAndRemoveUntil(
        context,
        NoAnimationPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    } catch (error) {
      if (!context.mounted) return;

      // Handle failure - warn user without unauthenticated navigation
      showErrorToast('logoutFailedPleaseRetry'.tr(), context);
    }
    // // Delete data in db
    // DBMasterLoginList().deleteAllLoginList().whenComplete(() async {
    //   showSuccessToast('logoutSuccess'.tr(), context);
    //   // Navigate
    //   Navigator.pushAndRemoveUntil(
    //     context,
    //     NoAnimationPageRoute(builder: (context) => const LoginView()),
    //     (route) => false,
    //   );

    //   // Clear token, username
    //   Storage().loginName = '';
    //   Storage().loginId = 0;
    //   Storage().token = '';
    //   Storage().selectedLocation = '';
    //   Storage().selectedLocationID = 0;
    //   Storage().transactionNo = '';
    //   Storage().trayWeight = 0.00;

    //   await DBJobData().deleteAllAddJob();
    //   await DBGoodsData().deleteAllGoodsData();
    // });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
