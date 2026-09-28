import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create internal storage to hold value temporarily
class Storage {
  // Initialize storage variable as internal storage
  static final Storage _storage = Storage._internal();

  factory Storage() => _storage;

  Storage._internal();

  FlutterSecureStorage secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String keyToken = 'auth_bearer_token';

  // Login
  int loginId = 0;
  String loginName = '';
  String loginPwd = '';
  String token = '';
  int selectedLocationID = 0;
  String selectedLocation = '';
  int areaIssueID = 0;
  String toLocation = '';
  double trayWeight = 0.0;
  String packageVersion = '';

  // Master
  int jobID = 0;
  String transactionNo = '';
  int selectedPickingID = 0;

  // Goods
  int goodsIssues = 0;
  int goodsReceive = 0;
  String plStatusState = '';

  String firstFreshInstall = '';
  Map<String, dynamic> selectedLoc = {};

  Future<void> saveToken(String token) async {
    await secureStorage.write(key: keyToken, value: token);
  }

  /// Read token from secure hardware-backed storage
  Future<String?> getToken() async {
    return await secureStorage.read(key: keyToken);
  }

  /// Delete token on logout or HTTP 401 Session Expired
  Future<void> deleteToken() async {
    await secureStorage.delete(key: keyToken);
  }
}
