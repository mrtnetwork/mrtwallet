import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class MacosBarcodeScannerView extends StatefulWidget {
  const MacosBarcodeScannerView({Key? key}) : super(key: key);

  @override
  State<MacosBarcodeScannerView> createState() =>
      _MacosBarcodeScannerViewState();
}

class _MacosBarcodeScannerViewState extends State<MacosBarcodeScannerView>
    with SafeState {
  final GlobalKey globalKey = GlobalKey();
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  StreamSubscription<BarcodeScannerResult>? stream;
  void init() async {
    final result = await MethodUtils.call(() async {
      BarcodeScannerParams? params;
      final rect = globalKey.getPosition();

      if (rect != null) {
        params = MacBarcodeScannerParams.fromRect(rect);
      }
      params ??= MacBarcodeScannerParams(
          width: context.mediaQuery.size.width - 20,
          height: (context.mediaQuery.size.height - kToolbarHeight) - 20,
          x: 10,
          y: 20);
      stream =
          (await BaseNativeMEthod.platform.startBarcodeScanner(param: params))
              .listen(onBarcodeData);
    }, delay: Duration.zero);
    if (result.hasError) {
      progressKey.errorText(result.error!);
    } else {
      progressKey.backToIdle();
    }
  }

  void onBarcodeData(BarcodeScannerResult barcode) {
    stream?.cancel();
    if (barcode.type == BarcodeScanerResultType.error) {
      progressKey.errorText(barcode.message?.tr ?? "");
    } else {
      progressKey.success(
          progressWidget: SuccessWithButtonAndCopyView(
            text: barcode.message!,
            bottomWidget: Column(
              children: [
                FilledButton(
                    onPressed: () {
                      context.pop(barcode.message);
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
  }

  @override
  void dispose() {
    stream?.cancel();
    stream = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialPageView(
        child: ScaffolPageView(
            appBar: AppBar(
              title: Text("qr_code_scanner".tr),
            ),
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
                        child: () => const Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera,
                              size: APPConst.double80,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }
}
