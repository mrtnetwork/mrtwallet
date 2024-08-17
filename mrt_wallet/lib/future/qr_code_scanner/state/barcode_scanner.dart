import 'package:flutter/material.dart';

import '../cross/core.dart'
    if (dart.library.js_interop) '../cross/web.dart'
    if (dart.library.io) '../cross/io.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<BarcodeScannerView> createState() => barcodeScannerState();
}
