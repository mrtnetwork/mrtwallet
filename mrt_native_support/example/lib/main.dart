import 'dart:js_interop';

import 'package:flutter/material.dart';

import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'dart:ui' as ui;

import 'package:mrt_native_support/web/api/api.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

@JS("localStorage")
extension type LocalStorage._(JSObject _) implements JSAny {
  external factory LocalStorage();
}
Map<String, String> getAll() {
  return Map<String, String>.from(localStorage.dartify() as Map);
}
// import 'package:mrt_native_support/web/api/mozila/api/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformInterface.appPlatform.isDesktop) {
    await PlatformInterface.instance.desktop.init();
    await PlatformInterface.instance.desktop.waitUntilReadyToShow();
    final pixelRatio =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

    await PlatformInterface.instance.desktop.setBounds(
        pixelRatio: pixelRatio,
        size: const WidgetSize(width: 400, height: 600));
    await PlatformInterface.instance.desktop.setResizable(false);
  }
  await PlatformInterface.instance.getConfig();
  runApp(const MaterialApp(home: MyWidget()));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              onPressed: () async {
              },
              child: const Text("test"))
        ],
      ),
    ));
  }
}
