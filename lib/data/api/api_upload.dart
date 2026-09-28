import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import 'utils.dart';

class APIUpload {
  Future<Map> uploadJob(List uploadData) async {
    var header = HttpClient().createHeader(type: RequestType.post);
    var route = HttpClient().createUri(ServerAddresses.jobUpload);

    Map uploadMap = {"transfers": uploadData};
    // print('Upload Payload: $uploadMap');
    var data = json.encode(uploadMap);

    try {
      var response = await http
          .post(route, headers: header, body: data)
          .timeout(const Duration(seconds: AppSettings.timeLimit));

      Map jsonResponse = json.decode(response.body);

      if (response.statusCode != 200) {
        throw jsonResponse['message'];
      }

      // print('Upload Response: $jsonResponse');
      return jsonResponse;
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
    }
  }
}
