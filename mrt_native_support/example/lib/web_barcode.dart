import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

class WebBarcodeScannerView extends StatefulWidget {
  const WebBarcodeScannerView({Key? key}) : super(key: key);

  @override
  State<WebBarcodeScannerView> createState() => _WebBarcodeScannerViewState();
}

class _WebBarcodeScannerViewState extends State<WebBarcodeScannerView> {
  static const String elementTypeName = "barcode_scanner_camera";
  bool supported = false;
  bool hasVideo = false;
  String? barcde;

  Timer? timer;
  html.MediaStream? stream;
  html.VideoElement? videoElement;

  Future<html.VideoElement> _loadVide() async {
    stream ??=
        await html.window.navigator.getUserMedia(video: true, audio: false);
    html.VideoElement videoElement = html.VideoElement()
      ..id = elementTypeName
      // ..width = 300
      // ..height = 300
      ..autoplay = true;
    videoElement.srcObject = stream;

    ui_web.platformViewRegistry
        .registerViewFactory(elementTypeName, (int viewId) => videoElement);
    videoElement.play();
    return videoElement;
  }
// [{"boundingBox":{"x":127.42864227294922,"y":189.7854461669922,"width":227.91250610351562,"height":229.14271545410156,"top":189.7854461669922,"right":355.34114837646484,"bottom":418.92816162109375,"left":127.42864227294922},"cornerPoints":[{"x":347.9927978515625,"y":189.7854461669922},{"x":355.3411560058594,"y":410.2154541015625},{"x":133.4198455810547,"y":418.92816162109375},{"x":127.42864227294922,"y":195.56773376464844}],"format":"qr_code","rawValue":"https://www.instagram.com/mrtglobalnetwork?utm_source=qr&igsh=NnlrNHlwbXNpNm95"}]

  void detectBarcode(
      html.BarcodeDetector detector, html.VideoElement image) async {
    final result = await detector.detect(image);
    if (result.isEmpty) return;
    str(result);
    final String data = result[0].rawValue;
    _dispose();
  }

  void str(Object? v) {
    final j = js_util.getProperty(js_util.globalThis, "JSON");
    final strf = js_util.callMethod(j, "stringify", [v]);
  }

  Future<void> init() async {
    final stream = await _loadVide();
    final detector = html.BarcodeDetector();
    timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      detectBarcode(detector, stream);
    });
    hasVideo = true;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    supported = js_util.hasProperty(html.window, "BarcodeDetector");
    if (supported) {
      init();
    }
  }

  void _dispose() {
    timer?.cancel();
    timer = null;
    videoElement?.pause();
    videoElement?.srcObject = null;
    stream?.getTracks().forEach((e) => e.stop());
    stream = null;
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
              child: !hasVideo
                  ? const SizedBox()
                  : const HtmlElementView(viewType: elementTypeName)),
        ],
      ),
    );
  }
}
