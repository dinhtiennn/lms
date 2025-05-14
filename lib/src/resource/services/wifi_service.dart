import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

typedef WifiListener = Function(bool enabled);

class WifiService {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  WifiService({WifiListener? listener}) {
    // Hủy bỏ subscription cũ nếu có
    if (_subscription != null) _subscription!.cancel();

    // Lắng nghe sự thay đổi kết nối
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Kiểm tra nếu có kết nối
      bool isConnected = results.any((result) => result != ConnectivityResult.none);

      // Gọi listener nếu có
      if (listener != null) {
        listener(isConnected);
      }
    });
  }

  static Future<bool> isConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<bool> isDisconnect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.none;
  }

  close() {
    _subscription?.cancel();
  }
}
