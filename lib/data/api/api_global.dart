import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import 'utils.dart';

class APIGlobal {
  // Call Handheld Location API
  Future<dynamic> getHandheldLocation() async {
    // var param = <String, dynamic>{
    //   'token': Storage().token,
    // };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.handheldLocation);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));
      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        // print('JSONRESPONSE API: $jsonResponse');

        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['locations'];
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

  // Inventory List
  Future<dynamic> getInventoryList(int category) async {
    var param = <String, dynamic>{
      'token': Storage().token,
      'category': category.toString(),
    };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.inventoryList, param);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));
      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        return jsonResponse;
      }
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
    }
  }

  // Area
  Future<dynamic> getAreaList(int? locationId) async {
    var param = <String, dynamic>{
      'token': Storage().token,
      'location_id': locationId.toString(),
    };

    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.area, param);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));
      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        // print('JSONRESPONSE API AREA: $jsonResponse');

        if (jsonResponse['success'] == true) {
          return jsonResponse;
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

  // Category
  Future<dynamic> getCategoryList() async {
    var param = <String, dynamic>{
      'token': Storage().token,
    };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.category, param);

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

  // GET STOCK BALANCE
  Future<dynamic> getStockBalance(String sku, int areaId) async {
    // Ensure all values are Strings for the Query Params
    var param = {
      'location_id': Storage().selectedLocationID.toString(),
      'sku': sku,
      'isGroup': 'true',
      'area': areaId.toString(),
    };

    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.stockBalance, param);

    try {
      var response = await http
          .get(route, headers: header)
          .timeout(const Duration(seconds: AppSettings.timeLimit));

      // Check for 401 (Auth issue) or 404 (Path issue)
      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        return jsonResponse;
      } else {
        // print('API Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } on TimeoutException catch (e) {
      debugPrint(e.toString());
      // Return a specific error or message to the UI
      return 'timeout';
    } catch (e) {
      // print('Connection Error: $e');
      throw e.toString();
    }
  }

  // Client
  Future<dynamic> getClientList() async {
    var param = <String, dynamic>{
      'category': 'warehouse',
    };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.client, param);

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

  // Vendor
  Future<dynamic> getVendorList() async {
    var param = <String, dynamic>{
      'category': 'warehouse',
    };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.vendor, param);

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

  // // Tray
  // Future<dynamic> getTrayList(
  //   String type,
  // ) async {
  //   var header = HttpClient().createHeader(type: RequestType.post);
  //   var route = HttpClient().createUri(ServerAddresses.tray);

  //   Map map = {
  //     "fw_tray_type": type,
  //   };
  //   var data = json.encode(map);

  //   try {
  //     var response = await http
  //         .post(route, headers: header, body: data)
  //         .timeout(const Duration(seconds: AppSettings.timeLimit));

  //     if (response.statusCode == 200) {
  //       Map jsonResponse = json.decode(response.body);

  //       if (jsonResponse['success'] == true) {
  //         // return jsonResponse['data'];
  //         return jsonResponse['data']['trays'];
  //       } else {
  //         return jsonResponse;
  //       }
  //     }
  //   } on TimeoutException {
  //     // We throw a clear string so the helper knows exactly what happened
  //     throw 'connectionTimeout'.tr();
  //   } catch (e) {
  //     throw e.toString();
  //   }
  // }

  // Rack
  Future<dynamic> getRackList(int areaId) async {
    var header = HttpClient().createHeader(type: RequestType.post);
    var route = HttpClient().createUri(ServerAddresses.rack);

    Map map = {
      "location_id": Storage().selectedLocationID.toString(),
      "area_id": areaId, // areaId,
    };
    var data = json.encode(map);

    try {
      var response = await http
          .post(route, headers: header, body: data)
          .timeout(const Duration(seconds: AppSettings.timeLimit));

      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['racks'];
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

  // Tray/Bakul & Trolley/Pallet
  Future<dynamic> getTrayTrolleyList() async {
    var header = HttpClient().createHeader(type: RequestType.post);
    var route = HttpClient().createUri(ServerAddresses.tray);

    Map map = {
      "location_id": Storage().selectedLocationID.toString(),
    };
    var data = json.encode(map);

    try {
      var response = await http
          .post(route, headers: header, body: data)
          .timeout(const Duration(seconds: AppSettings.timeLimit));

      if (response.statusCode == 200) {
        Map jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // return jsonResponse['data'];
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

  // Reason Code
  Future<dynamic> getReasonCodeList() async {
    // var param = <String, dynamic>{
    //   'category': 'warehouse',
    // };
    var header = HttpClient().createHeader(type: RequestType.get);
    var route = HttpClient().createUri(ServerAddresses.reasonCode);

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
