import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import 'utils.dart';

class APIUser {
  Future<Map> login(String username, String password) async {
    var header = HttpClient().createHeader(type: RequestType.post);
    var route = HttpClient().createUri(ServerAddresses.login);

    var pushToken =
        await Storage().secureStorage.read(key: 'push_token') ?? 'fcmToken';

    Map userMap = {
      "username": username,
      "password": password,
      "fcm_token": pushToken
    };

    var data = json.encode(userMap);

    try {
      var response = await http
          .post(route, headers: header, body: data)
          .timeout(const Duration(seconds: AppSettings.timeLimit));

      Map jsonResponse = json.decode(response.body);
      if (response.statusCode != 200 || (jsonResponse['status'] != 'success')) {
        throw jsonResponse['message'];
      }

      return jsonResponse;
    } on TimeoutException {
      // We throw a clear string so the helper knows exactly what happened
      throw 'connectionTimeout'.tr();
    } catch (e) {
      throw e.toString();
    }
  }
}
