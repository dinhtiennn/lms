import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/utils.dart';
import 'constants.dart';

normalTheme(BuildContext context) {
  return ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.black.withAlpha((255 * 0.3).round()),
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    fontFamily: fontFamilyRoboto,
    brightness: AppUtils.valueByMode(values: [Brightness.dark, Brightness.light]),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(color: black),
    ),
  );
}

darkTheme(BuildContext context) {
  return ThemeData(
    primarySwatch: Colors.blue,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
  );
}
