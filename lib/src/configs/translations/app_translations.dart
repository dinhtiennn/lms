import 'dart:ui';

import 'package:lms/src/configs/translations/lo_la_translation.dart';

import 'vi_vn_translation.dart';
import 'en_us_translations.dart';

abstract class AppTranslation {
  static Map<String, Map<String, String>> translations = {
    'en_US': enUs,
    'vi_VN': viVN,
    'lo_LA': loLa,
  };

  static List<Map<String, dynamic>> languages = [
    {'name': 'vi_VN', 'locale': Locale('vi', 'VN')},
    {'name': 'en_US', 'locale': Locale('en', 'US')},
    {'name': 'lo_LA', 'locale': Locale('lo', 'LA')},
  ];
}
