extension QuickDateTimeFormater on DateTime {
  static String _twoDigits(int n) {
    if (n >= 10) {
      return "$n";
    } else {
      return "0$n";
    }
  }

  String toDateAndTime() {
    return "$year-${_twoDigits(month)}-${_twoDigits(day)} "
        "${_twoDigits(hour)}:${_twoDigits(minute)}:${_twoDigits(second)}";
  }

  String toFileName() {
    return "${year}_${_twoDigits(month)}_${_twoDigits(day)}"
        "${_twoDigits(hour)}-${_twoDigits(minute)}-${_twoDigits(second)}";
  }
}
