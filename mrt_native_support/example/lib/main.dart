import 'package:flutter/material.dart';

import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformInterface.appPlatform == AppPlatform.windows) {
    await PlatformInterface.interface.window.init();
    await PlatformInterface.interface.window.waitUntilReadyToShow();
    await PlatformInterface.interface.window
        .setBounds(null, size: const Size(400, 600));
    await PlatformInterface.interface.window.setResizable(false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
              child: Center(
            child: InkWell(
              onTap: () async {},
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
