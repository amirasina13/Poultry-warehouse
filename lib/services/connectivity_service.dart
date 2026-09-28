import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum ConnectivityStatus { wifi, cellular, offline }

class ConnectivityService extends ChangeNotifier {
  ConnectivityStatus _status = ConnectivityStatus.offline;
  ConnectivityStatus get status => _status;
  ConnectivityStatus? previousStatus;

  StreamSubscription<ConnectivityResult>? _subscription;

  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  ConnectivityService._internal() {
    Connectivity().checkConnectivity().then(_updateStatus);
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(ConnectivityResult result) {
    previousStatus = _status; // Store the old status

    if (result == ConnectivityResult.wifi) {
      _status = ConnectivityStatus.wifi;
    } else if (result == ConnectivityResult.mobile) {
      _status = ConnectivityStatus.cellular;
    } else {
      _status = ConnectivityStatus.offline;
    }

    if (previousStatus != _status) {
      notifyListeners(); // This triggers the UI to rebuild everywhere
    }
  }

  Future<bool> check() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
