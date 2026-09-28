import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/config.dart';
import '../../data/api/api.dart';
import '../../services/services.dart';

class ApiUploadhelper {
  final APIUpload apiUpload;

  ApiUploadhelper() : apiUpload = APIUpload();

  Future<Map> uploadJob(uploadData) async {
    checkInternet();
    try {
      final value = await apiUpload.uploadJob(uploadData);

      if (value.isEmpty) {
        Fluttertoast.showToast(
          msg: 'noData'.tr(),
          fontSize: 16,
          backgroundColor: AppColors.red,
        );
        return {};
      }

      // If have value in API
      if (value['success'] == true) {
        return value;
      } else {
        String errorMessage =
            value['message']?.toString() ?? 'somethingWrong'.tr();

        final errors = value['errors'] as Map<String, dynamic>?;

        if (errors != null && errors.isNotEmpty) {
          errorMessage = errors.values
              .expand((errorList) => List<String>.from(errorList))
              .join('\n');
        }

        Fluttertoast.showToast(
          msg: errorMessage,
          fontSize: 16,
          backgroundColor: AppColors.red,
        );

        return {};
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: AppColors.red,
      );
      return {};
    }
  }

  checkInternet() async {
    bool isOnline = await ConnectivityService().check();

    if (!isOnline) {
      Fluttertoast.showToast(
        msg: "noInternet".tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return false; // Stop here if no internet
    } else {
      return true;
    }
  }
}
