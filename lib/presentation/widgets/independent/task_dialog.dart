import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import 'independent.dart';

class TaskDialog {
  static Future<bool> show(
    BuildContext context, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    VoidCallback? onUpload,
    double? verticalPadding,
    double? dialogHeight,
  }) async {
    final device = OrientationHelper(context);
    // context.watch<LanguageController>();

    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              contentPadding: device.isTablet() && device.isPotrait()
                  ? const EdgeInsets.symmetric(horizontal: 30)
                  : EdgeInsets.symmetric(
                      horizontal: 20, vertical: verticalPadding ?? 0),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              content: SizedBox(
                height: device.isTablet() && device.isPotrait()
                    ? dialogHeight ?? device.height() * 0.18
                    : dialogHeight ?? device.height() * 0.25,
                width: device.width() * 0.7,
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: onEdit,
                      child: Container(
                        width: device.width() * 0.15,
                        height: device.width() * 0.15,
                        margin: EdgeInsets.only(right: device.width() * 0.05),
                        decoration: BoxDecoration(
                          color: AppColors.editBtn,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/edit.svg',
                              width: device.width() * 0.03,
                              height: device.height() * 0.03,
                              colorFilter: ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                            TextUIDisplay(
                              labelText: 'edit'.tr().toUpperCase(),
                              fontSize: 14,
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                    if (onUpload != null)
                      InkWell(
                        onTap: onUpload,
                        child: Container(
                          width: device.width() * 0.15,
                          height: device.width() * 0.15,
                          margin: EdgeInsets.only(right: device.width() * 0.05),
                          decoration: BoxDecoration(
                            color: AppColors.downloadBtn,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/upload.svg',
                                width: device.width() * 0.03,
                                height: device.height() * 0.03,
                                colorFilter: ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                              TextUIDisplay(
                                labelText: 'upload'.tr().toUpperCase(),
                                fontSize: 14,
                                color: AppColors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: onDelete,
                      child: Container(
                        width: device.width() * 0.15,
                        height: device.width() * 0.15,
                        decoration: BoxDecoration(
                          color: AppColors.deleteBtn,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/delete.svg',
                              width: device.width() * 0.03,
                              height: device.height() * 0.03,
                              colorFilter: ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                            TextUIDisplay(
                              labelText: 'delete'.tr().toUpperCase(),
                              fontSize: 14,
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false; // default return false if dialog dismissed
  }
}
