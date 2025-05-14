import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfo {
  String? id;
  String? name;
  String? version;
  String? appVersion;

  DeviceInfo({this.id, this.version, this.name, this.appVersion});
}

class AppDeviceInfo {
  AppDeviceInfo._();

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static DeviceInfo? _deviceInfo;

  static String? get deviceID => _deviceInfo?.id;

  static String? get deviceName => _deviceInfo?.name;

  static String? get deviceVersion => _deviceInfo?.version;

  static String? get appVersion => _deviceInfo?.appVersion;

  static Future init() async {
    _deviceInfo = await getDeviceDetails();
    log(
        "AppDeviceInfo: $deviceID - $deviceName - $deviceVersion - $appVersion");
  }

  static Future<DeviceInfo?> getDeviceDetails() async {
    DeviceInfo? device;
    final appInfo = await PackageInfo.fromPlatform();
    try {
      if (Platform.isAndroid) {
        var info = await _deviceInfoPlugin.androidInfo;
        device = DeviceInfo(
          name: info.model,
          version: info.version.release,
          id: info.id,
          appVersion: appInfo.version,
        );
      } else if (Platform.isIOS) {
        var info = await _deviceInfoPlugin.iosInfo;
        device = DeviceInfo(
          name: info.name,
          version: info.systemVersion,
          id: info.identifierForVendor,
          appVersion: appInfo.version,
        );
      }
    } catch (e) {
      log('Failed to get platform version: $e');
    }
    return device;
  }
}