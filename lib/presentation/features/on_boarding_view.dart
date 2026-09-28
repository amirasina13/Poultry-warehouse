import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../custom_page_route.dart';
import '../../helper/orientation_helper.dart';
import '../widgets/independent/independent.dart';
import 'login_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);

    return SafeArea(
      child: PoultryScaffold(
        background: AppColors.whiteBg,
        isFullFooter: true,
        body: Column(
          children: [
            // Top SVG Illustration
            Expanded(
              // flex: 3,
              child: SizedBox(
                width: device.width(),
                child: const Image(
                  image: AssetImage(
                    'assets/images/background.webp',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Bottom Section
            Expanded(
              // flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.whiteBg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: device.height() * 0.04),
                        Text.rich(
                          TextSpan(
                            text: "Dedicated ",
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.linkColor),
                            children: [
                              TextSpan(
                                text: "Warehouse \n Management ",
                                style: TextStyle(color: AppColors.mainColor),
                              ),
                              const TextSpan(
                                text: "Application",
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: device.height() * 0.04),
                        Text(
                          "startedText".tr(),
                          style: TextStyle(
                              color: AppColors.linkColor, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // Button
                    ButtonUIDisplay(
                      height: device.height() / 20,
                      width: device.width() * 0.5,
                      labelText: 'getStarted'.tr(),
                      backgroundColor: AppColors.mainColor,
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          NoAnimationPageRoute(
                              builder: (context) => const LoginView()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
