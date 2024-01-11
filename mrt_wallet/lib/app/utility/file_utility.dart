import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class FileUtility {
  static Future<(String, String)?> qrCodeToFile(
      {required String data,
      required String uderImage,
      required ColorScheme color}) async {
    try {
      final fileName = "${DateTime.now().toFileName()}.png";
      ui.Image? image = await QrPainter(
        data: data,
        version: QrVersions.auto,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: color.onBackground,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: color.onBackground,
        ),
      ).toImage(500);
      final ByteData? bufferBytes = await _QrCodeMarkerPainter(
              qrImage: image,
              margin: 10,
              imageSize: 500,
              data: uderImage,
              textColor: color.onBackground,
              backgroundColor: color.background)
          .toImageData();
      final List<int> bufferData = bufferBytes!.buffer.asUint8List();
      final write = await CrossFileWriter.writeBytes(
          bytes: bufferData, fileName: fileName, validate: false);
      return (write, fileName);
    } catch (e) {
      return null;
    }
  }
}

class _QrCodeMarkerPainter extends CustomPainter {
  final Color textColor;
  final double margin;
  final ui.Image qrImage;
  final Color backgroundColor;
  late final Paint _paint = Paint()
    ..color = backgroundColor
    ..style = ui.PaintingStyle.fill;
  final double imageSize;
  final String data;

  _QrCodeMarkerPainter(
      {required this.qrImage,
      this.margin = 10,
      required this.imageSize,
      required this.data,
      required this.textColor,
      required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    const borderRadius = Radius.circular(12);
    final rect = RRect.fromRectAndRadius(
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
        borderRadius);
    canvas.drawRRect(rect, _paint);
    canvas.drawImage(qrImage, Offset(margin * 2, margin), _paint);
    final ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.justify,
      fontSize: 14,
    ))
          ..pushStyle(ui.TextStyle(color: textColor, fontSize: 14))
          ..addText(AppLinkConst.appGithub);
    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size.width - 12.0 - 12.0));
    canvas.drawParagraph(paragraph, Offset(25, (imageSize + 10)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  ui.Picture toPicture(double size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(size, size));
    return recorder.endRecording();
  }

  Future<ui.Image> toImage(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    return await toPicture(size).toImage(size.toInt(), size.toInt());
  }

  Future<ByteData?> toImageData() async {
    final image =
        await toImage(imageSize + margin * 4, format: ui.ImageByteFormat.png);
    return image.toByteData(format: ui.ImageByteFormat.png);
  }
}
