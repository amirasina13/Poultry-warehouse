import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/config.dart';

class LoadingWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color? textColor;

  LoadingWidget({
    super.key,
    Color? backgroundColor,
    Color? textColor,
  })  : backgroundColor = backgroundColor ?? AppColors.white,
        textColor = textColor ?? AppColors.darkGrey;

  @override
  Widget build(BuildContext context) {
    // context.watch<LanguageController>();

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'loading'.tr(),
              style: TextStyle(
                fontFamily: AppSettings.fontFamilyMain,
                color: textColor,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            CircularProgressIndicator(
              color: textColor!.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
