import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mrt_native/a.dart';
import 'package:mrt_native/web_barcode.dart';

import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/platform_interface.dart';

// await PlatformInterface.interface.window.init();
// await PlatformInterface.interface.window.waitUntilReadyToShow();
// await PlatformInterface.interface.window
//     .setBounds(null, size: const Size(500, 700));
// await PlatformInterface.interface.window.setResizable(false);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformInterface.appPlatform.isDesktop) {
    await PlatformInterface.interface.desktop.init();
    await PlatformInterface.interface.desktop.waitUntilReadyToShow();
    await PlatformInterface.interface.desktop
        .setBounds(null, size: const Size(400, 600));
    await PlatformInterface.interface.desktop.setResizable(false);
  }

  runApp(const MaterialApp(home: MyWidget()));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with WindowListener {
  @override
  void initState() {
    super.initState();
  }

  void write() async {
    final plat = PlatformInterface.interface;
    final path = await plat.path();
    final naame = "${path.support}${DateTime.now().microsecond}.txt";
    final f = File(naame);
    await f.create(recursive: true);
    final v = List.generate(1000, (index) => "m").join();
    await f.writeAsString(v);
    plat.launchUri(f.path);

    await plat.share(Share.file(f.absolute.path, "ssds",
        text: "hasheddm", subject: "jafar2"));
  }

  // final detector = html.BarcodeDetector();
  // html.VideoElement videoElement = html.VideoElement()
  //   ..id = 'videoElement'
  //   ..width = 300
  //   ..height = 300
  //   ..autoplay = true;
  // bool hasVideo = false;
  // Future<html.MediaStream> loadUserMEdia() async {
  //   final a =
  //       await html.window.navigator.getUserMedia(video: true, audio: false);
  //   videoElement.srcObject = a;

  //   platformViewRegistry.registerViewFactory(
  //     'videoElement',
  //     (int viewId) => videoElement,
  //   );

  //   setState(() {
  //     print("done!");
  //     hasVideo = true;
  //   });
  //   videoElement.play();
  //   await Future.delayed(const Duration(seconds: 1));
  //   return a;
  // }

  // Timer? timer;
  //  timer?.cancel();
  //               timer = null;
  //               final ms = await loadUserMEdia();

  //               // print(js.hasProperty(html.window, "BarcodeDetector"));
  //               // final detector = js.callConstructor(
  //               //     js.getProperty(html.window, "BarcodeDetector"), [
  //               //   {
  //               //     "formats": ['qr_code']
  //               //   }
  //               // ]);
  //               print("detector ${js.hasProperty(detector, "detect")}");
  //               timer = Timer.periodic(const Duration(milliseconds: 500),
  //                   (a) async {
  //                 print("pre");
  //                 final result = await detector.detect(videoElement);
  //                 str(result);
  //                 print("resul $result");
  //                 // await js.callMethod(detector, "detect", [videoElement]);
  //                 // str(result);
  //               });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: Container(
              color: Colors.black,
            ),
          ),
          Expanded(
              child: Center(
            child: InkWell(
              onTap: () async {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => WebBarcodeScannerView()));
                // html.window.requestAnimationFrame(callback);
                // html.window.barc
                // const barcodeDetector = new BarcodeDetector({ formats: ['qr_code'] });

                // await a.
                // print(js.hasProperty(js.globalTh is, "navigator"));
                // final nav = js.getProperty(js.globalThis, "navigator");
                // print(js.hasProperty(nav, "mediaDevices"));
                // const constraints = {
                //   "video": {
                //     "facingMode": 'environment' // Use the back camera
                //   }
                // };
                // final devices = await js.callMethod(
                //     nav.mediaDevices, "getUserMedia", [constraints]);
                // str(devices);
                // print("devices ${}");
                // for (final i in (devices as )) {}
                // print("devices $devices");
                // final enumerateDevices =
                //     js.getProperty(mediaDevices, "enumerateDevices");
                // print(js.hasProperty(mediaDevices, "enumerateDevices"));
              },
              child: const Icon(
                Icons.abc,
                size: 120,
              ),
            ),
          ))
        ],
      ),
    ));
  }
}

class NativeName {}

class Name {
  Name.fromJson(Map<String, dynamic> json)
      : common = json["common"],
        official = json["official"];
  final String common;
  final String official;
}

class Test {
  Test.fromJson(Map<String, dynamic> json) : name = Name.fromJson(json["name"]);
  final Name name;
}
