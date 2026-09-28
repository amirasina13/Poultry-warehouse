import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import '../../helper/helper.dart';
import 'utils.dart';

class APITransaction {
  // CREATE
  Future<dynamic> createTransaction(String transaction, int type,
      int locationId, int reasonId, String remark) async {
    var header = HttpClient().createHeader(type: RequestType.post);
    var route = HttpClient().createUri(ServerAddresses.createTransaction);

    Map map = {
      "transaction": transaction,
      "type": ValueParser.formatValue(type),
      "location_id": ValueParser.formatValue(locationId),
      "reason_id": ValueParser.formatStringPayload(reasonId),
      "remark": remark,
    };
    var data = json.encode(map);

    try {
      var response = await http
          .post(route, headers: header, body: data)
          .timeout(const Duration(seconds: AppSettings.timeLimit));

      if (response.statusCode == 401) {
        throw 'sessionExpired'.tr();
      }

      if (response.statusCode >= 500) {
        throw 'serverError'.tr();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw 'requestFailed'.tr();
      }

      Map jsonResponse = json.decode(response.body);

      return jsonResponse;
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
      // throw Exception('Something is wrong. Please try again later.');
    }
  }
}
