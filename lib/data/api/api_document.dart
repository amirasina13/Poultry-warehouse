import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import 'utils.dart';

class APIDocumentList {
  // Call picking list API
  Future<dynamic> getPickingList(
      {int? transferType,
      String? jobOrderNo,
      int? areaID,
      required bool isList,
      required isPagination,
      int? pageCount,
      int? pageLimit}) async {
    var param = <String, dynamic>{
      'location_id': Storage().selectedLocationID.toString(),
      'transfer_type': transferType.toString(),
      'isList': isList.toString(),
      'isPagination': isPagination.toString()
    };
    // Dynamically include param only if provided and non-empty
    if (areaID != null) {
      param['area'] = areaID.toString();
    }
    if (jobOrderNo != null && jobOrderNo.trim().isNotEmpty) {
      param['job_order_no'] = jobOrderNo.trim();
    }
    if (isPagination == true) {
      param['limit'] = pageLimit.toString();
      param['page'] = pageCount.toString();
    }

    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.getPickingList, param);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));

      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          if (isPagination == false) {
            return jsonResponse['data'];
          }
          return jsonResponse;
        } else {
          return jsonResponse;
        }
      }

      if (response.statusCode == 401) {
        throw 'sessionExpired'.tr();
      }

      if (response.statusCode >= 500) {
        throw 'serverError'.tr();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw 'requestFailed'.tr();
      }
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
    }
  }

  // Call picking list details API
  Future<dynamic> getPickingListDetails({String? docNo}) async {
    var param = <String, dynamic>{
      'doc_no': docNo.toString(),
    };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route =
        HttpClient().createUri(ServerAddresses.getPickingListDetails, param);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));
      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        } else {
          return jsonResponse;
        }
      }
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
    }
  }

  // Call document no list API
  Future<dynamic> getDocumentList(
      {int? type,
      String? locationType,
      required bool isList,
      required isPagination,
      int? pageCount,
      int? pageLimit}) async {
    var param = <String, dynamic>{
      'location_id': Storage().selectedLocationID.toString(),
      'location_type': locationType,
      'type': type.toString(),
      'isList': isList.toString(),
      'isPagination': isPagination.toString()
    };

    if (isPagination == true) {
      param['limit'] = pageLimit.toString();
      param['page'] = pageCount.toString();
    }

    var header = HttpClient().createHeader(type: RequestType.get);
    var route =
        HttpClient().createUri(ServerAddresses.getDocumentNoList, param);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));
      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        } else {
          return jsonResponse;
        }
      }
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
    }
  }

  // Call GIN Doc details API
  Future<dynamic> getDocumentDetails({String? docNo}) async {
    var param = <String, dynamic>{
      'doc_no': docNo.toString(),
    };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route =
        HttpClient().createUri(ServerAddresses.getDocumentNoDetails, param);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));
      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        } else {
          return jsonResponse;
        }
      }
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
    }
  }
}
