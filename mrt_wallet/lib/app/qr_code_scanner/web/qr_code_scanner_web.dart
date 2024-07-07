// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class WebBarcodeScannerView extends StatefulWidget {
  const WebBarcodeScannerView({Key? key}) : super(key: key);

  @override
  State<WebBarcodeScannerView> createState() => _WebBarcodeScannerViewState();
}

class _WebBarcodeScannerViewState extends State<WebBarcodeScannerView> {
  String id = "barcode_scanner_camera";
  bool supported = false;
  bool hasVideo = false;
  String? barcde;
  final GlobalKey globalKey = GlobalKey();
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  Timer? timer;
  html.MediaStream? stream;
  html.VideoElement? videoElement;

  Future<html.VideoElement> _loadVide() async {
    stream ??=
        await html.window.navigator.getUserMedia(video: true, audio: false);
    final String id = DateTime.now().microsecondsSinceEpoch.toString();
    html.VideoElement videoElement = html.VideoElement()
      ..id = id
      ..autoplay = true;

    videoElement.srcObject = stream;

    ui_web.platformViewRegistry
        .registerViewFactory(id, (int viewId) => videoElement);
    videoElement.play();
    return videoElement;
  }

  void detectBarcode(
      html.BarcodeDetector detector, html.VideoElement image) async {
    final result = await detector.detect(image);
    if (result.isEmpty) return;
    final String message = result[0].rawValue;
    _dispose();
    progressKey.success(
        progressWidget: SuccessWithButtonAndCopyView(
          text: message,
          bottomWidget: Column(
            children: [
              FilledButton(
                  onPressed: () {
                    context.pop(message);
                  },
                  child: Text("submit".tr)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        progressKey.progress(ProgressWithTextView(
                            text: "getting_scanner_ready".tr));
                        init();
                      },
                      icon: const Icon(Icons.camera))
                ],
              ),
            ],
          ),
        ),
        backToIdle: false);
  }

  Future<void> init() async {
    final result = await MethodUtils.call(() async {
      supported = js_util.hasProperty(html.window, "BarcodeDetector");
      final stream = await _loadVide();
      final detector = html.BarcodeDetector();
      return (stream, detector);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!);
    } else {
      progressKey.backToIdle();
      id = result.result.$1.id;
      videoElement = result.result.$1;
      await Future.delayed(const Duration(seconds: 1));
      timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
        detectBarcode(result.result.$2, result.result.$1);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
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
    return MaterialPageView(
        child: ScaffolPageView(
            appBar: AppBar(title: Text("qr_code_scanner".tr)),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: WidgetConstant.padding20,
                    child: Container(
                      key: globalKey,
                      child: PageProgress(
                        backToIdle: APPConst.milliseconds100,
                        initialStatus: StreamWidgetStatus.progress,
                        initialWidget: ProgressWithTextView(
                            text: "getting_scanner_ready".tr),
                        key: progressKey,
                        child: () => HtmlElementView(viewType: id),
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }
}
