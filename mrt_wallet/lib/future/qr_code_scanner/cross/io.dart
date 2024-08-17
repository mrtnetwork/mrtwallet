import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/qr_code_scanner/state/barcode_scanner.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

State<BarcodeScannerView> barcodeScannerState() =>
    _MacosBarcodeScannerViewState();

class _MacosBarcodeScannerViewState extends State<BarcodeScannerView>
    with SafeState {
  late bool isSecure;
  final GlobalKey globalKey = GlobalKey();
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  StreamSubscription<BarcodeScannerResult>? stream;
  void init() async {
    final result = await MethodUtils.call(() async {
      BarcodeScannerParams? params;
      final rect = globalKey.getPosition();

      if (rect != null) {
        params = MacBarcodeScannerParams.fromRect(WidgetRect(
            height: rect.height,
            width: rect.width,
            x: rect.bottomLeft.dx,
            y: rect.bottomLeft.dx));
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
      progressKey.errorText(barcode.message?.tr ?? "", backToIdle: false);
    } else if (barcode.type == BarcodeScanerResultType.cancel) {
      progressKey.success(
          progressWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera, size: 80),
              WidgetConstant.height8,
              Text("barcode_scanning_terminated".tr),
              WidgetConstant.height20,
              IconButton(
                  onPressed: () {
                    progressKey.progress(
                        ProgressWithTextView(text: "getting_scanner_ready".tr));
                    init();
                  },
                  icon: const Icon(Icons.camera))
            ],
          ),
          backToIdle: false);
    } else {
      progressKey.success(
          progressWidget: SuccessBarcodeProgressView(
            text: barcode.message!,
            secure: isSecure,
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
    isSecure = context.getNullArgruments<bool>() ?? false;
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
                        child: (c) => const Column(
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
