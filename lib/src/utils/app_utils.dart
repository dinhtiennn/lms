import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

import '../configs/configs.dart';
import '../presentation/widgets/dialog/custom_toast.dart';
import 'app_prefs.dart';

export '../presentation/widgets/dialog/custom_toast.dart';

class AppUtils {
  AppUtils._();

  // static const MethodChannel _channel = MethodChannel('myChanel');

  static String getTimeAgo(DateTime? time) {
    if (time == null) {
      return '';
    }
    final now = DateTime.now();
    final difference = now.difference(time!);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  static final List<List<Color>> gradients = [
    [Color(0xFF1A237E), Color(0xFF3949AB)],
    [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    [Color(0xFF004D40), Color(0xFF00796B)],
    [Color(0xFFE65100), Color(0xFFF57C00)],
    [Color(0xFF880E4F), Color(0xFFC2185B)],
  ];

  static List<Color> getGradientForCourse(String? courseTitle) {
    if (courseTitle == null || courseTitle.isEmpty) {
      return [Colors.transparent, Colors.transparent];
    }

    int hashCode = courseTitle.toLowerCase().hashCode.abs();

    int index = hashCode % gradients.length;
    return gradients[index];
  }

  static void toast(String? message,
      {Duration? duration,
      NotificationPosition? notificationPosition,
      CustomToastType type = CustomToastType.error}) {
    if (message == null) return;
    showOverlayNotification(
      (context) {
        return CustomToast(
          message: message,
          type: type,
        );
      },
      position: notificationPosition ?? NotificationPosition.top,
      duration: duration ?? const Duration(milliseconds: 2000),
    );
  }

  static const List<String> _themes = ['dark', 'light'];

  static dynamic valueByMode(
      {List<String> themes = _themes, required List<dynamic> values}) {
    try {
      for (int i = 0; i < themes.length; i++) {
        if (AppPrefs.appMode == themes[i]) {
          if (i < values.length) {
            return values[i];
          } else {
            values.first;
          }
        }
      }
      return values.first;
    } catch (e) {
      return values.first;
    }
  }

  static void restart(BuildContext context) {
    Get.offAndToNamed(Routers.navigation);
  }

  // static void openGoogleMaps(String latlng) async {
  //   await _channel.invokeMapMethod<String, dynamic>(
  //     'open_google_maps',
  //     <String, dynamic>{'latlng': latlng},
  //   );
  // }

  static String pathMediaToUrl(String? url) {
    if (url == null || url.startsWith('http')) {
      return url ?? 'url_not_exits';
    }
    return '${AppEndpoint.baseImageUrl}$url';
  }

  static String pathMediaToUrlAndRamdomParam(String? url) {
    //server không nhận pram nên truyền cũng không ảnh hưởng
    // Tạo số ngẫu nhiên và thêm vào URL
    var random = Random();
    int randomNumber =
        random.nextInt(1000000); // Tạo số ngẫu nhiên từ 0 đến 999999
    url = '$url?a=$randomNumber';
    return url;
  }

  static String convertDateTime2String(DateTime? dateTime,
      {String format = 'yy-MM-dd'}) {
    if (dateTime == null) return "";
    return DateFormat(format).format(dateTime);
  }

  static DateTime? convertString2DateTime(String? dateTime,
      {String format = "yyyy-MM-ddTHH:mm:ss.SSSZ"}) {
    if (dateTime == null) return null;
    return DateFormat(format).parse(dateTime);
  }

  static String convertString2String(String? dateTime,
      {String inputFormat = "yyyy-MM-ddTHH:mm:ss.SSSZ",
      String outputFormat = "yyyy-MM-dd"}) {
    if (dateTime == null) return "";
    final input = convertString2DateTime(dateTime, format: inputFormat);
    return convertDateTime2String(input, format: outputFormat);
  }

  static String minimum(int? value) {
    if (value == null) return "00";
    return value < 10 ? "0$value" : "$value";
  }

  static String convertPhoneNumber(String phone, {String code = "+84"}) {
    return '$code${phone.substring(1)}';
  }

  static String convertPrice(price, {bool isCurrency = true}) {
    String result = "";
    try {
      result = isCurrency
          ? "${NumberFormat(",###", "vi").format(price)}đ"
          : NumberFormat(",###", "vi").format(price);
    } catch (e) {}
    return result;
  }

  static void copyToClipBoard(String text) {
    toast("copy_to_clipboard", type: CustomToastType.success);
    Clipboard.setData(ClipboardData(text: text));
  }

  // chuyển qua app khác
  static void openBrowserUrl({required Uri uri, bool inApp = false}) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: inApp ? LaunchMode.inAppWebView : LaunchMode.externalApplication,
      );
    }
  }

  static List<dynamic> parseMathString(String input) {
    RegExp regex = RegExp(r'(\$\$(.*?)\$\$|\$(.*?)\$|\*\*(.*?)\*\*)');
    // Tìm cả **in đậm**, $math$, $$math$$
    List<dynamic> result = [];
    int lastIndex = 0;

    for (RegExpMatch match in regex.allMatches(input)) {
      // Thêm đoạn text trước đoạn đặc biệt
      if (match.start > lastIndex) {
        result.add(input.substring(lastIndex, match.start));
      }

      // Xác định loại nội dung
      if (match.group(2) != null) {
        // $$ math $$ hoặc $ math $
        result.add({"formula": match.group(2) ?? match.group(3)});
      } else if (match.group(4) != null) {
        // **bold**
        result.add({"bold": match.group(4)});
      }

      lastIndex = match.end;
    }

    // Thêm đoạn text cuối cùng (nếu có)
    if (lastIndex < input.length) {
      result.add(input.substring(lastIndex));
    }

    return result;
  }

  static String formatDateToDDMMYYYY(String isoDateString) {
    try {
      final date = DateTime.parse(isoDateString).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    } catch (e) {
      return ''; // hoặc log lỗi
    }
  }

  static String formatDateToISO(String dateStr) {
    if (dateStr.isEmpty) return '';
    List<String> parts = dateStr.split('/');
    if (parts.length != 3) return '';
    String day = parts[0].padLeft(2, '0');
    String month = parts[1].padLeft(2, '0');
    String year = parts[2];
    return '$year-$month-${day}T00:00:00Z';
  }

  static String getFileType(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi'].contains(ext)) {
      return 'video';
    }
    return 'file';
  }

  static String getQuestionTypeText(String type) {
    switch (type) {
      case 'SINGLE_CHOICE':
        return 'Chọn một đáp án';
      case 'MULTIPLE_CHOICE':
        return 'Chọn nhiều đáp án';
      default:
        return type;
    }
  }

  static bool isExpired(DateTime? expiredAt) {
    if (expiredAt == null) return false;
    return DateTime.now().isAfter(expiredAt);
  }

  static String? toOffsetDateTimeString(DateTime? dt) {
    if (dt == null) return null;

    final offset = dt.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final formatted = dt.toIso8601String().split('.').first;

    return '$formatted$sign$hours:$minutes';
  }

  static DateTime? fromUtcStringToVnTime(String? dateStr) {
    if (dateStr?.isEmpty ?? true) return null;
    try {
      return DateTime.parse(dateStr!).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String getLearningDurationTypeLabel(String type) {
    if (type.contains('UNLIMITED')) {
      return 'Không có thời hạn';
    } else {
      return 'Có thời hạn';
    }
  }

  static AccountModel? getOtherAccount(List<AccountModel> members, String currentUsername) {
    return members.firstWhere(
          (account) => account.accountUsername != currentUsername,
    );
  }

}
