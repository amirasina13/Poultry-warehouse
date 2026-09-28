import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../data/api/api.dart';
import '../../services/services.dart';

class ApiGlobalHelper {
  final APIGlobal apiGlobal;

  ApiGlobalHelper() : apiGlobal = APIGlobal();

  /// Fetch location list from API
  Future<List<dynamic>> getLocationFromAPI() async {
    checkInternet();
    try {
      final value = await apiGlobal.getHandheldLocation();

      if (value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return [];
      }

      // Filter out location_type == FRM and only status == 1
      final List<Map<String, dynamic>> filtered = value
          .where((entry) =>
              entry['location_type'] != 'FRM' &&
              entry['location_type'] != 'C-FRM' &&
              entry['status'] == 1)
          .cast<Map<String, dynamic>>()
          .toList();

      return filtered;
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  /// Fetch category list from API
  Future<List<dynamic>> getCategoryList() async {
    checkInternet();
    try {
      final value = await apiGlobal.getCategoryList();

      if (value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return [];
      }

      // If have value in API
      if (value != null) {
        // Filter the data based on status == 1
        List filteredData =
            // Assuming status is an integer. If it's a string, use '1' instead of 1.
            value
                .where((entry) => entry['status'] == 1 && entry['type'] != 1)
                .toList();

        return filteredData;
      } else {
        String message = value['message'] ?? '';

        Fluttertoast.showToast(
            msg: "${'noData'.tr()} - $message",
            fontSize: 16,
            backgroundColor: Colors.red);

        return [];
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  /// Fetch category list from API
  Future<List<dynamic>> getInventoryList(int category) async {
    List skuNameList = [];

    checkInternet();

    try {
      final value = await apiGlobal.getInventoryList(category);

      if (value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return [];
      }

      // If have value in API
      List<String> desiredCategories = [
        'finished_good',
        'raw_material',
        'packaging'
      ];

      // If have value in API
      var data = value['data'];

      // Filter the data to only include output
      for (var item in data) {
        if (desiredCategories
            .any((category) => item['inventory_category'].contains(category))) {
          skuNameList.add(item);
          // print("OUTPUT: $skuNameList");
        }
      }

      return skuNameList;
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  /// Fetch Vendor list from API
  Future<List<dynamic>> getVendorList() async {
    checkInternet();
    try {
      final value = await apiGlobal.getVendorList();

      if (value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return [];
      }

      return value;
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  /// Fetch client list from API
  Future<List<dynamic>> getClientList() async {
    checkInternet();

    try {
      final value = await apiGlobal.getClientList();

      if (value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return [];
      }

      return value;
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  /// Fetch area list from API
  Future<List<dynamic>> getAreaList(int? locationId) async {
    checkInternet();
    try {
      final value = await apiGlobal.getAreaList(locationId);

      if (value.isEmpty) {
        Fluttertoast.showToast(
          msg: 'noData'.tr(),
          fontSize: 16,
          backgroundColor: Colors.red,
        );

        return [];
      }

      // If have value in API
      if (value is Map<String, dynamic> && value.containsKey('data')) {
        // Filter the data based on status == 1
        List filteredData =
            value['data'].where((entry) => entry['status'] == 1).toList();
        // Assuming status is an integer. If it's a string, use '1' instead of 1.

        // // If using text field as drop down
        List filteredAreaList = filteredData
            .map((entry) => {
                  'id': entry['id'],
                  'name': entry['name'],
                  'code': entry['code'],
                })
            .toList();

        return filteredAreaList;
      } else {
        // String message =
        //     value['message'] ?? ''; // Capture the 'message' from the response
        // Fluttertoast.showToast(
        //     msg: "${'noData'.tr()} - $message",
        //     fontSize: 16,
        //     backgroundColor: Colors.red);

        return [];
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );

      return [];
    }
  }

  /// Fetch Stock Balance from API
  Future<List<dynamic>> getStockBalance(String selectedSku, int areaID) async {
    checkInternet();
    try {
      final value = await apiGlobal.getStockBalance(selectedSku, areaID);

      if (value == 'timeout') {
        Fluttertoast.showToast(
          msg: "The server is taking too long to respond. Please try again.",
          fontSize: 16,
          backgroundColor: Colors.red,
        );

        return [];
      }

      if (value == null || value.isEmpty) {
        return [];
      }

      if (value['data'].isEmpty) {
        return [];
      }

      /// -------IF FROM API NOT GROUP ---------
      // // Map to hold the grouped elements
      // final Map<String, Map<String, dynamic>> groupedMap = {};

      // for (var item in value['data']) {
      //   // Generate a unique key combination
      //   //     final String key =
      //   //         "${item['inventory_id']}_${item['batch_no']}_${item['prod_date']}_${item['exp_date']}";
      //   final String key =
      //       "${item['inventory_id']}_${item['batch_no']}_${item['prod_date']}_${item['exp_date']}";

      //   if (!groupedMap.containsKey(key)) {
      //     // 1. Create a deep copy of the map
      //     var newItem = Map<String, dynamic>.from(item);

      //     // 2. Initialize the 'groupedId' array with the current item's ID
      //     newItem['grouped_ids'] = [item['id']];

      //     newItem['is_grouped'] = true;

      //     groupedMap[key] = newItem;
      //   } else {
      //     // 3. Key exists -> Add the current item's ID to the existing 'groupedId' list
      //     groupedMap[key]!['grouped_ids'].add(item['id']);

      //     // 4. Accumulate weights and quantities as before
      //     double currentWeight =
      //         double.tryParse(groupedMap[key]!['weight'].toString()) ?? 0.0;
      //     double itemWeight = double.tryParse(item['weight'].toString()) ?? 0.0;

      //     int currentQty =
      //         int.tryParse(groupedMap[key]!['qty'].toString()) ?? 0;
      //     int itemQty = int.tryParse(item['qty'].toString()) ?? 0;

      //     groupedMap[key]!['weight'] = (currentWeight + itemWeight).toString();
      //     groupedMap[key]!['qty'] = (currentQty + itemQty).toString();
      //   }
      // }

      // // 4. Convert the grouped map values back into a List
      // final List<Map<String, dynamic>> groupedResult =
      //     groupedMap.values.toList();
      // return groupedResult;

      return value['data'];
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  /// Get Racks from API
  Future<List<dynamic>> getRack(int areaId) async {
    checkInternet();
    try {
      final value = await apiGlobal.getRackList(areaId);

      if (value == 'timeout') {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //     content: Text("Server timed out. Check your connection.")));

        Fluttertoast.showToast(
          msg: "The server is taking too long to respond. Please try again.",
          fontSize: 16,
          backgroundColor: Colors.red,
        );

        return [];
      }

      if (value == null || value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return [];
      }

      return value;
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  /// Get Tray Pallet from API
  Future<Map<String, dynamic>> getTrayTrolleyList() async {
    checkInternet();
    try {
      final value = await apiGlobal.getTrayTrolleyList();

      if (value == 'timeout') {
        Fluttertoast.showToast(
          msg: "The server is taking too long to respond. Please try again.",
          fontSize: 16,
          backgroundColor: Colors.red,
        );

        return {};
      }

      if (value == null || value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return {};
      }

      return value;
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
      return {};
    }
  }

  /// Fetch Reason Code list from API
  Future<List<dynamic>> getReasonCodeList() async {
    checkInternet();
    try {
      final value = await apiGlobal.getReasonCodeList();

      if (value.isEmpty) {
        // Fluttertoast.showToast(
        //   msg: 'noData'.tr(),
        //   fontSize: 16,
        //   backgroundColor: Colors.red,
        // );
        return [];
      }

      List filteredData =
          // Assuming status is an integer. If it's a string, use '1' instead of 1.
          value
              .where((entry) =>
                  entry['status'] == 1 && entry['type'] == 'Warehouse')
              .toList();

      return filteredData;
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(), //'somethingWentWrong'.tr(),
        fontSize: 16,
        backgroundColor: Colors.red,
      );
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
