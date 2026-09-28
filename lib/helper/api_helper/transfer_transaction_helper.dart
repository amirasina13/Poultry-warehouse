import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/config.dart';
import '../../data/api/api.dart';
import '../../services/services.dart';

class ApiTransferTxnhelper {
  final APITransaction apiTransaction;

  ApiTransferTxnhelper() : apiTransaction = APITransaction();

  Future<String> createTransaction(String transaction, int type, int locationId,
      int reasonId, String remark) async {
    // transaction = IN / OUT
    // type = 1 *same like portal

    checkInternet();

    try {
      final value = await apiTransaction.createTransaction(
          transaction, type, locationId, reasonId, remark);

      if (value.isEmpty) {
        Fluttertoast.showToast(
          msg: 'noData'.tr(),
          fontSize: 16,
          backgroundColor: AppColors.red,
        );
        return '';
      }

      if (!value['success']) {
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
        return '';
      }

      // If have value in API
      if (value is Map<String, dynamic> && value.containsKey('data')) {
        return value['data']['transaction_no'];
      } else {
        return '';
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: AppColors.red,
      );
      rethrow;
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
