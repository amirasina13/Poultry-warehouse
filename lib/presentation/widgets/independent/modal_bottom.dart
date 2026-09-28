import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import 'independent.dart';

class JobBottomSheet {
  /// [onUpload] is optional → if not provided, the Upload button will not show.
  static void show(
    BuildContext context, {
    VoidCallback? onEdit,
    required VoidCallback onDelete,
    VoidCallback? onUpload,
    bool isUploading = false,
    bool isUploadingAll = false,
  }) {
    final device = OrientationHelper(context);

    showEditButton() {
      if (onEdit == null) {
        return const SizedBox.shrink();
      }

      return ButtonUIDisplay(
        labelText: "editRecord".tr(),
        onPressed: onEdit,
        backgroundColor: AppColors.editBtn,
        icon: SvgPicture.asset(
          'assets/icons/edit.svg',
          width: device.width() * 0.02,
          height: device.height() * 0.02,
          colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
        width: device.width() * 0.7,
      );
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            child: Container(
              height: device.isTablet() && device.isPotrait()
                  ? (onUpload != null)
                      ? device.height() * 0.30
                      : device.height() * 0.25
                  : !device.isTablet() && device.isPotrait()
                      ? device.height() * 0.30
                      : device.height() * 0.4,
              width: device.width(),
              color: AppColors.white,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "manageTask".tr(),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  /// Edit record button
                  showEditButton(),
                  const SizedBox(height: 10),

                  /// Upload record button (optional)
                  if (onUpload != null)
                    (isUploadingAll || isUploading)
                        ? ButtonUIDisplay(
                            labelText: "uploadRecord".tr(),
                            onPressed: () {},
                            backgroundColor: Colors.grey[500]!,
                            icon: SvgPicture.asset(
                              'assets/icons/upload.svg',
                              width: device.width() * 0.02,
                              height: device.height() * 0.02,
                              colorFilter: ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                            width: device.width() * 0.7,
                            // height: device.height() * 0.04,
                          )
                        : ButtonUIDisplay(
                            labelText: "uploadRecord".tr(),
                            onPressed: onUpload,
                            backgroundColor: AppColors.downloadBtn,
                            icon: SvgPicture.asset(
                              'assets/icons/upload.svg',
                              width: device.width() * 0.02,
                              height: device.height() * 0.02,
                              colorFilter: ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                            width: device.width() * 0.7,
                            //height: device.height() * 0.04,
                          ),
                  const SizedBox(height: 10),

                  /// Delete record button
                  ButtonUIDisplay(
                    labelText: "deleteRecord".tr(),
                    onPressed: onDelete,
                    backgroundColor: AppColors.deleteBtn,
                    icon: SvgPicture.asset(
                      'assets/icons/delete.svg',
                      width: device.width() * 0.02,
                      height: device.height() * 0.02,
                      colorFilter:
                          ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                    ),
                    width: device.width() * 0.7,
                    //height: device.height() * 0.04,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
