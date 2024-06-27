import 'dart:io';

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
              child: Center(
            child: InkWell(
              onTap: () async {
                // write();
                // return;
                final p = await PlatformInterface.interface.getDeviceInfo();
                print("g $p");
                // print("paths: $p");
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
