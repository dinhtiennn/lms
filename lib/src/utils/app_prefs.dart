import 'dart:ui';

import 'package:get_storage/get_storage.dart';
import 'package:lms/src/resource/model/model.dart';

class AppPrefs {
  AppPrefs._();

  static final GetStorage _box = GetStorage('AppPref');
  static const String _keyRole = 'role';

  static initListener() async {
    await GetStorage.init("AppPref");
  }

  static set appMode(String? data) => _box.write('appMode', data);

  static String? get appMode => _box.read('appMode');

  static set appLanguage(Locale? data) {
    if (data != null) {
      _box.write('appLanguage',
          {'languageCode': data.languageCode, 'countryCode': data.countryCode});
    }
  }

  static Locale? get appLanguage {
    final Map<String, dynamic>? localeMap = _box.read('appLanguage');
    if (localeMap != null) {
      final String languageCode = localeMap['languageCode'];
      final String? countryCode = localeMap['countryCode'];
      return Locale(languageCode, countryCode);
    }
    return null;
  }

  static set onboardScreen(bool? data) => _box.write('onboardScreen', data);

  static bool? get onboardScreen => _box.read('onboardScreen');

  static set accessToken(String? data) => _box.write('accessToken', data);

  static String? get accessToken => _box.read('accessToken');

  static set refreshToken(String? data) => _box.write('refreshToken', data);

  static String? get refreshToken => _box.read('refreshToken');

  static set password(String? data) => _box.write('password', data);

  static String? get password => _box.read('password');

  static set countNotification(int? data) =>
      _box.write('countNotification', data);

  static int? get countNotification => _box.read('countNotification');

  static List<String> get historySearch {
    final data = _box.read('history_search');
    if (data == null) return [];

    return data is List<String>
        ? data
        : List<String>.from(data.map((x) => x.toString()));
  }

  static setUser<T>(T? data) {
    final key = 'user_${T.toString()}';
    if (data == null) {
      _box.remove(key);
    } else {
      _box.write(key, (data as dynamic).toJson());
    }
  }


  static T? getUser<T>(T Function(Map<String, dynamic>) fromJson) {
    final data = _box.read('user_${T.toString()}');
    if (data == null) return null;
    return fromJson(data);
  }
}
