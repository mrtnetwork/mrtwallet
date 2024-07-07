import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/platform_interface.dart';

class AAAA extends StatefulWidget {
  const AAAA({Key? key}) : super(key: key);

  @override
  State<AAAA> createState() => _AAAAState();
}

class _AAAAState extends State<AAAA> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey _widgetKey = GlobalKey();
  Rect? _widgetRect;
  StreamSubscription<BarcodeScannerResult>? sub;
  void _getWidgetInfo() async {
    final support = await PlatformInterface.interface.hasBarcodeScanner();
    if (!support) {
      print("does not have");
      return;
    }
    final RenderBox renderBox =
        _widgetKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    setState(() {
      _widgetRect =
          Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    });
    final r = MacBarcodeScannerParams.fromRect(_widgetRect!);
    print('Widget Rect: $_widgetRect ${r.toJson()}');
    sub = (await PlatformInterface.interface.startBarcodeScanner(param: r))
        .listen(
      (event) {
        print("event ${event.type.name} ${event.message}");
        sub?.cancel();
        sub = null;
      },
    );
  }

  @override
  void dispose() {
    sub?.cancel();
    sub = null;
    PlatformInterface.interface.stopBarcodeScanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("qweqweqw"),
      ),
      body: Container(
        color: Colors.red,
        margin: EdgeInsets.all(40),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                key: _widgetKey,
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _getWidgetInfo();
                        },
                        child: Text(
                          "size",
                          style: TextStyle(color: Colors.red),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
