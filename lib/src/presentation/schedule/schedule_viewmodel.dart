import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';

class ScheduleViewModel extends BaseViewModel {
  ValueNotifier<DateTime> date = ValueNotifier(DateTime.now());
  ValueNotifier<List<DateTime>> days = ValueNotifier([]);

  init() async {
    initDays(date.value.year, date.value.month);
  }

  void initDays(int year, int month) {
    days.value = getWeeksInMonth(year, month);
    days.notifyListeners();
  }

  List<DateTime> getWeeksInMonth(int year, int month) {
    List<DateTime> days = [];
    DateTime firstDayOfMonth = DateTime(year, month, 1);

    DateTime firstDayOfWeek = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));

    DateTime currentDay = firstDayOfWeek;

    while (currentDay.month == month || currentDay.isBefore(firstDayOfMonth)) {
      for (int i = 0; i < 7; i++) {
        days.add(currentDay);
        currentDay = currentDay.add(const Duration(days: 1));
      }
    }

    return days;
  }

  void setDate(DateTime dateSelect) {
    date.value = dateSelect;
    date.notifyListeners();
  }

  void addMonths(int months) {
    int newMonth = date.value.month + months;
    int newYear = date.value.year;

    // Điều chỉnh năm nếu newMonth <= 0
    while (newMonth <= 0) {
      newYear -= 1;
      newMonth += 12;
    }

    // Điều chỉnh nếu tháng vượt quá 12
    while (newMonth > 12) {
      newYear += 1;
      newMonth -= 12;
    }

    date.value = DateTime(newYear, newMonth, DateTime.now().day);
    date.notifyListeners();
    initDays(date.value.year, date.value.month);
  }
}
