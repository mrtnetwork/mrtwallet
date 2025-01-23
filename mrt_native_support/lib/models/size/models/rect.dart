class WidgetRect {
  final double height;
  final double width;
  final double x;
  final double y;
  final double? devicePixelRatio;
  const WidgetRect(
      {required this.height,
      required this.width,
      required this.x,
      required this.y,
      this.devicePixelRatio});

  static WidgetRect? fromString(String? v) {
    if (v == null) return null;
    try {
      final numbers = v.split('_').map((e) => double.tryParse(e)).toList();
      return WidgetRect(
          height: numbers[0]!,
          width: numbers[1]!,
          x: numbers[2]!,
          y: numbers[3]!,
          devicePixelRatio: numbers[4]!);
    } catch (_) {
      return null;
    }
  }

  WidgetRect copyWith(
      {double? height,
      double? width,
      double? x,
      double? y,
      double? devicePixelRatio}) {
    return WidgetRect(
        height: height ?? this.height,
        width: width ?? this.width,
        x: x ?? this.x,
        y: y ?? this.y,
        devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio);
  }

  @override
  String toString() {
    return "${height}_${width}_${x}_${y}_$devicePixelRatio";
  }
}
