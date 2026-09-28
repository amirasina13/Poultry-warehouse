import 'package:package_info_plus/package_info_plus.dart';

import '../../config/config.dart';
import '../../config/environment.dart';

enum RequestType { post, get, put, delete }

class HttpClient {
  Map<String, String> createHeader({required RequestType type}) {
    switch (type) {
      case RequestType.post:
        {
          var header = <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'App-Version': "Warehouse - ${Storage().packageVersion}",
          }..addAll(_getBasicAuthHeader());

          return header;
        }
      case RequestType.get:
        {
          var header = <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'App-Version': "Warehouse - ${Storage().packageVersion}",
          }..addAll(_getBasicAuthHeader());
          return header;
        }
      case RequestType.put:
        return _getBasicAuthHeader();
      case RequestType.delete:
        return _getBasicAuthHeader();
    }
  }

  Map<String, String> _getBasicAuthHeader() {
    return <String, String>{
      'Authorization': 'Bearer ${Storage().token}'
      // 'Authorization':
      //     'Basic NmZlYTA1ZWZkY2FlNDIyZjYzYjFmMDZmMWVhZTkwZTQ6NWVkZjdhMmI4MmZjOWU5OWI5ZGUzODg5YjM5M2Y4YTM=',
    };
  }

  Uri createUri(String route, [Map<String, dynamic> param = const {}]) {
    var baseUri = Uri.parse(EnvironmentConfig.apiUrl + route);

    // Only add query parameters if the map is not empty
    if (param.isNotEmpty) {
      var urlWithParams = baseUri.replace(queryParameters: param);
      return urlWithParams;
    }

    return baseUri;
  }

  Future<String> getBuildVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return "Warehouse - $version+$buildNumber";
  }
}
