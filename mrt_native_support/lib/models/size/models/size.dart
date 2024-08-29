class WidgetSize {
  final double width;
  final double height;
  const WidgetSize({required this.width, required this.height});
  Map<String, dynamic> toJson() {
    return {"width": width, "height": height};
  }
}
