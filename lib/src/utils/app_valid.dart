import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppValid {
  AppValid._();

  static validatePhone() {
    return (value) {
      if (value == null || value.length == 0) return 'valid_enter_phone'.tr;
      RegExp regex = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
      if (!regex.hasMatch(value)) return 'valid_phone'.tr;
    };
  }

  static validateFullName() {
    return (value) {
      if (value == null || value.length <= 3) {
        return 'valid_full_name'.tr;
      }
      return null;
    };
  }

  static validateEmail() {
    return (value) {
      if (value == null || value.length == 0) {
        return 'valid_enter_email'.tr;
      } else {
        RegExp regex = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
        if (!regex.hasMatch(value)) {
          return 'valid_email'.tr;
        } else {
          return null;
        }
      }
    };
  }

  static validateEmail2() {
    return (value) {
      RegExp regex = RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
      if (!regex.hasMatch(value)) {
        return 'valid_email'.tr;
      } else {
        return null;
      }
    };
  }

  static FormFieldValidator<String> validatePassword() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Nhập mật khẩu mới'.tr;
      }

      if (value.length < 8) {
        return 'Mật khẩu phải đúng yêu cầu'.tr;
      }

      final hasUppercase = value.contains(RegExp(r'[A-Z]'));
      final hasLowercase = value.contains(RegExp(r'[a-z]'));
      final hasDigit = value.contains(RegExp(r'\d'));
      final hasSpecialChar = value.contains(RegExp(r'[!@#\$&*~]'));

      if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecialChar) {
        return 'Mật khẩu phải đúng yêu cầu'.tr;
      }

      return null;
    };
  }

  static validatePasswordConfirm(TextEditingController controller) {
    return (value) {
      if (controller.text != value) {
        return 'Mật khẩu không khớp';
      } else {
        return null;
      }
    };
  }

  static validatePhoneNumber() {
    RegExp regex = RegExp(r'^(?:[+0]9)?[0-9]{10}$');

    return (value) {
      if (value == null || value.length == 0) {
        return 'valid_enter_phone'.tr;
      } else if (value.length != 10) {
        return 'valid_phone'.tr;
      } else if (!regex.hasMatch(value)) {
        return 'valid_phone'.tr;
      } else {
        return null;
      }
    };
  }

  static validateRequireEnter({String? titleValid}) {
    return (value) {
      if (value == null || value.length == 0)
        return titleValid ?? 'register_field_cannot_empty'.tr;
    };
  }

  static validateNumber() {
    RegExp regex = RegExp(r'[0-9]');

    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'register_field_cannot_empty'.tr;
      } else if (!regex.hasMatch(value.replaceAll(".", ""))) {
        return 'number_valid'.tr;
      } else {
        return null;
      }
    };
  }

  static FormFieldValidator<String> validateHuscEmail() {
    RegExp regex = RegExp(r'^[\w-\.]+@husc\.edu\.vn$');

    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Trường email không được để trống';
      } else if (!regex.hasMatch(value)) {
        return 'Email phải có định dạng @husc.edu.vn';
      } else {
        return null;
      }
    };
  }

  static String? validateStartTime(
    String? startDateText,
    String? timeStartText,
  ) {
    if (startDateText == null ||
        startDateText.isEmpty ||
        timeStartText == null ||
        timeStartText.isEmpty) {
      return 'Không được bỏ trống';
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    try {
      final date = dateFormat.parseStrict(startDateText);
      final time = timeFormat.parseStrict(timeStartText);

      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (!startDateTime.isAfter(DateTime.now())) {
        return 'Thời gian bắt đầu phải ở tương lai';
      }

      return null;
    } catch (e) {
      return 'Định dạng ngày hoặc giờ không hợp lệ';
    }
  }

  static String? validateEndDate(String? startDateText, String? endDateText) {
    if (startDateText == null || endDateText == null)
      return 'Không được bỏ trống!';
    if (startDateText.isEmpty || endDateText.isEmpty)
      return 'Không được bỏ trống!';

    final format = DateFormat('dd/MM/yyyy');

    try {
      final startDate = format.parseStrict(startDateText);
      final endDate = format.parseStrict(endDateText);

      if (endDate.isBefore(startDate)) {
        return 'Vui lòng chọn ngày lớn hơn $startDateText';
      }
    } catch (e) {
      return 'Định dạng ngày không hợp lệ (dd/MM/yyyy)';
    }

    return null;
  }

  static String? validateEndTime(
    String? startDateText,
    String? startTimeText,
    String? endDateText,
    String? timeEndText,
  ) {
    if (startDateText == null ||
        startDateText.isEmpty ||
        startTimeText == null ||
        startTimeText.isEmpty ||
        endDateText == null ||
        endDateText.isEmpty ||
        timeEndText == null ||
        timeEndText.isEmpty) {
      return 'Không được bỏ trống';
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    try {
      final startDate = dateFormat.parseStrict(startDateText);
      final startTime = timeFormat.parseStrict(startTimeText);

      final endDate = dateFormat.parseStrict(endDateText);
      final endTime = timeFormat.parseStrict(timeEndText);

      final startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startTime.hour,
        startTime.minute,
      );

      final endDateTime = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        endTime.hour,
        endTime.minute,
      );

      if (!endDateTime.isAfter(startDateTime)) {
        return 'Thời gian kết thúc phải sau thời gian bắt đầu';
      }

      return null;
    } catch (e) {
      return 'Định dạng ngày hoặc giờ không hợp lệ';
    }
  }
}
