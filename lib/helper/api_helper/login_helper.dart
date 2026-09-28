import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/model/login_model.dart';
import '../../config/config.dart';
import '../../custom_page_route.dart';
import '../../data/api/api.dart';
import '../../data/local/local.dart';
import '../../presentation/features/home_view.dart';
import '../../presentation/widgets/independent/independent.dart';
import '../../services/services.dart';
import '../helper.dart';

class ApiLoginHelper {
  final APIUser apiUser;

  ApiLoginHelper() : apiUser = APIUser();

  // Login api
  Future<bool> loginAcc(username, password, context) async {
    var dateTime = DateTimeParser();

    checkInternet();

    try {
      final value = await apiUser.login(username, password);

      if (value['status'] == 'success') {
        final token = value['token'] ?? '';
        final userData = value['data'];

        if (value['data']['fh_status'] == '1') {
          // Save bearer token securely in Keychain/KeyStore
          await Storage().saveToken(token);

          Storage().loginName = userData['fh_name'];
          Storage().loginId = userData['fh_id'];
          Storage().token = token;

          await DBMasterLoginList().deleteAllLoginList();
          await DBMasterLoginList().createMenuItem(LoginModel(
            loginId: value['data']['fh_id'],
            username: value['data']['fh_name'],
            // password: base64Encode(utf8.encode(password)),
            email: value['data']['email'] ?? '',
            // token: value['token'],
            createdAt: dateTime.getCurrentDateTime(),
            updatedAt: dateTime.getCurrentDateTime(),
          ));

          showSuccessToast('loginMessage'.tr(), context);

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              NoAnimationPageRoute(builder: (context) => const HomeView()),
              (route) => false,
            );
          }

          return true;
        } else {
          String message = value['message'] ?? '';
          Fluttertoast.showToast(
            msg: "${'inactiveAccount'.tr()} - $message",
            fontSize: 16,
            backgroundColor: Colors.red,
          );
          return false;
        }
      } else {
        Fluttertoast.showToast(
          msg: "${value['message']}",
          fontSize: 16,
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(), //'somethingWentWrong'.tr(),
          fontSize: 16,
          backgroundColor: AppColors.deleteBtn);

      return false;
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
