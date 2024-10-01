import 'package:flutter/material.dart';

extension QuickDateTimeFormater on DateTime {
  static DateTime fromSecondsSinceEpoch(int s) {
    return DateTime.fromMillisecondsSinceEpoch(s * 1000);
  }

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, "0");
    // if (n >= 10) {
    //   return "$n";
    // } else {
    //   return "0$n";
    // }
  }

  String toDateAndTimeWithSecound() {
    return "$year-${_twoDigits(month)}-${_twoDigits(day)} "
        "${_twoDigits(hour)}:${_twoDigits(minute)}:${_twoDigits(second)}";
  }

  String toDateAndTime() {
    return "$year-${_twoDigits(month)}-${_twoDigits(day)} "
        "${_twoDigits(hour)}:${_twoDigits(minute)}";
  }

  String toTimeOnlyStr() {
    return "${_twoDigits(hour)}:${_twoDigits(minute)}";
  }

  String toOnlyDateStr() {
    return "$year-${_twoDigits(month)}-${_twoDigits(day)}";
  }

  DateTime toOnlyDate() {
    return DateTime(year, month, day);
  }

  TimeOfDay timeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
  bool get isAfterNow => toUtc().isAfter(DateTime.now().toUtc());
}
