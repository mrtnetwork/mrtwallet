import 'package:flutter/material.dart' show Rect;

abstract class BarcodeScannerParams {
  Map<String, dynamic> toJson();
}

class EmptyBarcodeScannerParams implements BarcodeScannerParams {
  const EmptyBarcodeScannerParams();
  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class MacBarcodeScannerParams implements BarcodeScannerParams {
  final double? x;
  final double? y;
  final double width;
  final double height;
  const MacBarcodeScannerParams(
      {required this.width, required this.height, this.x, this.y});
  factory MacBarcodeScannerParams.fromRect(Rect rect) {
    return MacBarcodeScannerParams(
        height: rect.height,
        width: rect.width,
        x: rect.bottomLeft.dx,
        y: rect.bottomLeft.dx);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'x': x ?? 0,
      'y': y ?? 0,
      'width': width,
      'height': height,
    };
  }
}
