import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import 'independent.dart';

class OptionDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required Widget message,
    required String typeDialog, // delete | upload | reminder | alert
    double? verticalPadding,
    double? dialogHeight,
  }) async {
    final device = OrientationHelper(context);

    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              // contentPadding: device.isTablet()
              //     ? EdgeInsets.symmetric(horizontal: 30)
              //     : EdgeInsets.symmetric(horizontal: 20),
              contentPadding: device.isTablet() && device.isPotrait()
                  ? EdgeInsets.symmetric(
                      horizontal: 20, vertical: verticalPadding ?? 10)
                  : EdgeInsets.symmetric(
                      horizontal: 20, vertical: verticalPadding ?? 0),
              // insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              content: SizedBox(
                height: device.isTablet() && device.isPotrait()
                    ? dialogHeight ?? device.height() * 0.22
                    : dialogHeight ?? device.height() * 0.25,
                // height: device.isPotrait()
                //     ? !device.isTablet()
                //         ? device.height() * 0.3
                //         : device.height() * 0.35
                //     : device.height() * 0.35,
                width: device.width() * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Title + Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: !device.isTablet() ? 250 : null,
                          child: Text(
                            title,
                            maxLines: !device.isTablet() ? 2 : 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: typeDialog == 'delete'
                                  ? AppColors.deleteBtn
                                  : AppColors.linkColor,
                            ),
                          ),
                        ),
                        typeDialog == 'alert'
                            ? const SizedBox()
                            : InkWell(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 30),
                                  child:
                                      Icon(Icons.close, color: AppColors.red),
                                ),
                                onTap: () {
                                  Navigator.pop(context,
                                      false); // return false if canceled
                                },
                              ),
                      ],
                    ),

                    /// Message
                    message,

                    const SizedBox(height: 25),

                    /// Buttons
                    typeDialog == 'reminder' || typeDialog == 'alert'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ButtonUIDisplay(
                                labelText: typeDialog == 'alert'
                                    ? "okay".tr()
                                    : "confirm".tr(),
                                // height: device.isPotrait()
                                //     ? device.height() / 24
                                //     : device.height() / 16,
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                backgroundColor: AppColors.editBtn,
                              )
                            ],
                          )
                        : Row(
                            children: [
                              /// Cancel button
                              Expanded(
                                  child: ButtonUIDisplay(
                                labelText: "cancel".tr(),
                                width: 100,
                                // height: device.isPotrait()
                                //     ? device.height() / 24
                                //     : device.height() / 16,
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                backgroundColor: AppColors.greyShade600,
                              )),
                              const SizedBox(width: 15),

                              /// Yes button
                              Expanded(
                                  child: ButtonUIDisplay(
                                labelText: 'yes'.tr(),
                                width: 100,
                                // height: device.isPotrait()
                                //     ? device.height() / 24
                                //     : device.height() / 16,
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                backgroundColor: typeDialog == 'upload'
                                    ? AppColors.downloadBtn
                                    : AppColors.deleteBtn,
                              )),
                            ],
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
