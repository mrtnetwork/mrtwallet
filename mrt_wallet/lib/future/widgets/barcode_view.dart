import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class BarcodeView extends StatefulWidget {
  const BarcodeView(
      {super.key,
      required this.title,
      required this.barcodeData,
      this.underBarcodeWidget,
      this.shareSubject,
      this.shareText,
      this.underBarcode,
      this.secure = false});
  final Widget title;
  final String barcodeData;
  final String? underBarcode;
  final Widget? underBarcodeWidget;
  final String? shareText;
  final String? shareSubject;
  final bool secure;

  @override
  State<BarcodeView> createState() => _BarcodeViewState();
}

class _BarcodeViewState extends State<BarcodeView> with SafeState {
  final buttomState = GlobalKey<StreamWidgetState>();
  bool showBarcode = false;
  Future<void> share() async {
    buttomState.process();
    try {
      final toFile = await FileUtility.qrCodeToFile(
          data: widget.barcodeData,
          uderImage: widget.underBarcode ?? widget.barcodeData,
          color: context.theme.colorScheme);

      if (!context.mounted) return;
      await ShareUtility.shareFile(toFile!.$1, toFile.$2,
          subject: widget.shareSubject,
          text: widget.shareText,
          mimeType: FileMimeTypes.imagePng);
      buttomState.success();
    } catch (e) {
      buttomState.error();
    }
  }

  void show() {
    showBarcode = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title,
        WidgetConstant.height8,
        Stack(
          children: [
            ClipRRect(
              borderRadius: WidgetConstant.border8,
              child: QrImageView(
                data: widget.barcodeData,
                backgroundColor: context.colors.secondary,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: context.theme.colorScheme.onSecondary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: context.theme.colorScheme.onSecondary,
                ),
              ),
            ),
            if (widget.secure)
              Positioned.fill(
                  child: AnimatedSwitcher(
                duration: AppGlobalConst.animationDuraion,
                child: SizedBox(
                  width: context.mediaQuery.size.width,
                  key: ValueKey(showBarcode),
                  child: !showBarcode
                      ? Container(
                          decoration: BoxDecoration(
                              borderRadius: WidgetConstant.border8,
                              color: context.colors.secondaryContainer
                                  .withOpacity(0.98)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton.icon(
                                  onPressed: show,
                                  icon: const Icon(Icons.remove_red_eye),
                                  label: Text("show_barcode".tr))
                            ],
                          ),
                        )
                      : WidgetConstant.sizedBox,
                ),
              ))
          ],
        ),
        WidgetConstant.height20,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamWidget(
              backToIdle: AppGlobalConst.animationDuraion,
              key: buttomState,
              buttomWidget: FilledButton.icon(
                onPressed: share,
                icon: const Icon(Icons.share),
                label: Text("share_barcode".tr),
              ),
            )
          ],
        ),
        widget.underBarcodeWidget ?? WidgetConstant.sizedBox,
      ],
    );
  }
}
