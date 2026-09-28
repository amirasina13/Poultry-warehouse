import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/config.dart';
import '../../data/api/api.dart';
import '../../services/services.dart';

class ApiDocumentHelper {
  final APIDocumentList apiDocumentList;

  ApiDocumentHelper() : apiDocumentList = APIDocumentList();

  List filteredPickingList = [];

  Future<dynamic> getPickingList({
    int? pickingListID,
    int? transferType,
    String? jobOrderNo,
    int? areaID,
    required bool isList,
    required isPagination,
    int? pageLimit,
    int? pageCount,
  }) async {
    checkInternet();

    try {
      if (isPagination == false) {
        final List<dynamic> value = await apiDocumentList.getPickingList(
            transferType: transferType,
            jobOrderNo: jobOrderNo,
            areaID: areaID,
            isList: isList,
            isPagination: isPagination,
            pageLimit: pageLimit,
            pageCount: pageCount);

        if (value.isEmpty) {
          return [];
        }

        return value;
      } else {
        var value = await apiDocumentList.getPickingList(
            transferType: transferType,
            jobOrderNo: jobOrderNo,
            areaID: areaID,
            isList: isList,
            isPagination: isPagination,
            pageLimit: pageLimit,
            pageCount: pageCount);

        if (value.isEmpty) {
          return {};
        }

        return value;
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(), //'somethingWentWrong'.tr(),
          fontSize: 16,
          backgroundColor: AppColors.deleteBtn);
      rethrow;
    }
  }

  Future<dynamic> getPickingListDetails({String? docNo}) async {
    checkInternet();
    try {
      final value = await apiDocumentList.getPickingListDetails(docNo: docNo);

      if (value.isEmpty) {
        return [];
      }

      return value['details'];
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(), //'somethingWentWrong'.tr(),
          fontSize: 16,
          backgroundColor: AppColors.deleteBtn);
      return [];
    }
  }

  Future<dynamic> getDocumentNoList({
    int? type,
    String? locationType,
    // bool? getGinDoc,
    // String? ginDocNo,
    required bool isList,
    required isPagination,
    int? pageLimit,
    int? pageCount,
  }) async {
    checkInternet();
    try {
      if (isPagination == false) {
        final List<dynamic> value = await apiDocumentList.getDocumentList(
            type: type,
            locationType: locationType,
            isList: isList,
            isPagination: isPagination,
            pageLimit: pageLimit,
            pageCount: pageCount);

        if (value.isEmpty) {
          return [];
        }

        return value;
      } else {
        var value = await apiDocumentList.getDocumentList(
            type: type,
            locationType: locationType,
            isList: isList,
            isPagination: isPagination,
            pageLimit: pageLimit,
            pageCount: pageCount);

        if (value.isEmpty) {
          return {};
        }

        return value;
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(), //'somethingWentWrong'.tr(),
          fontSize: 16,
          backgroundColor: AppColors.deleteBtn);
      return [];
    }
  }

  Future<dynamic> getDocumentNoDetails({String? docNo}) async {
    checkInternet();
    try {
      final value = await apiDocumentList.getDocumentDetails(docNo: docNo);

      if (value.isEmpty) {
        return [];
      }

      return value['details'];
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(), //'somethingWentWrong'.tr(),
          fontSize: 16,
          backgroundColor: AppColors.deleteBtn);
      return [];
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
