import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/extention/extention.dart'
    show QuickContextAccsess, Translate;
import 'barcode_view.dart';
import 'container_with_border.dart';
import 'text_widget.dart';
import 'widget_constant.dart';

class CopyTextIcon extends StatefulWidget {
  const CopyTextIcon(
      {super.key,
      required this.dataToCopy,
      this.widget,
      this.size,
      this.messaage,
      this.color});
  final String dataToCopy;
  final double? size;
  final String? messaage;
  final Color? color;
  final Widget? widget;

  @override
  State<CopyTextIcon> createState() => CopyTextIconState();
}

class CopyTextIconState extends State<CopyTextIcon> {
  bool inCopy = false;
  void onTap() async {
    if (inCopy) return;
    inCopy = true;
    setState(() {});

    await Clipboard.setData(ClipboardData(text: widget.dataToCopy));
    if (_close) return;
    if (mounted) {
      context.showAlert(widget.messaage ?? "copied_to_clipboard".tr);
    }
    await Future.delayed(APPConst.oneSecoundDuration);
    inCopy = false;
    setState(() {});
  }

  bool _close = false;
  @override
  void setState(VoidCallback fn) {
    if (_close || !mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    _close = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = AnimatedSwitcher(
      duration: APPConst.animationDuraion,
      child: Icon(
        inCopy ? Icons.check_circle : Icons.copy,
        size: widget.size,
        key: ValueKey<bool>(inCopy),
        color: widget.color,
      ),
    );
    return InkWell(
      onTap: onTap,
      customBorder: RoundedRectangleBorder(
        borderRadius: WidgetConstant.border8,
      ),
      child: widget.widget != null
          ? Row(
              children: [
                Expanded(child: widget.widget!),
                WidgetConstant.width8,
                icon
              ],
            )
          : icon,
    );
  }
}

class CopyTextWithBarcode extends StatefulWidget {
  const CopyTextWithBarcode(
      {super.key,
      required this.dataToCopy,
      required this.widget,
      required this.barcodeTitle,
      this.secureBarcode = false,
      this.underBarcodeWidget,
      this.barcodeWidget,
      this.size,
      this.messaage,
      this.color});
  final String dataToCopy;
  final double? size;
  final String? messaage;
  final Color? color;
  final Widget widget;
  final Widget? barcodeWidget;
  final String barcodeTitle;
  final Widget? underBarcodeWidget;
  final bool secureBarcode;

  @override
  State<CopyTextWithBarcode> createState() => CopyTextWithBarcodeState();
}

class CopyTextWithBarcodeState extends State<CopyTextWithBarcode> {
  bool inCopy = false;
  void onTap() async {
    if (inCopy) return;
    inCopy = true;
    setState(() {});

    await Clipboard.setData(ClipboardData(text: widget.dataToCopy));
    if (_close) return;
    if (mounted) {
      context.showAlert(widget.messaage ?? "copied_to_clipboard".tr);
    }
    await Future.delayed(APPConst.oneSecoundDuration);
    inCopy = false;
    setState(() {});
  }

  bool _close = false;
  @override
  void setState(VoidCallback fn) {
    if (_close || !mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    _close = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      inCopy ? Icons.check_circle : Icons.copy,
      size: widget.size,
      key: ValueKey<bool>(inCopy),
      color: widget.color,
    );
    return AnimatedSwitcher(
      duration: APPConst.animationDuraion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        key: ValueKey<bool>(inCopy),
        children: [
          widget.widget,
          WidgetConstant.width8,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    context.openSliverDialog(
                        (ctx) => BarcodeView(
                            secure: widget.secureBarcode,
                            underBarcodeWidget: widget.underBarcodeWidget,
                            title: widget.barcodeWidget ??
                                ContainerWithBorder(
                                    child: CopyTextIcon(
                                        dataToCopy: widget.dataToCopy,
                                        widget: OneLineTextWidget(
                                            widget.dataToCopy,
                                            maxLine: 3))),
                            barcodeData: widget.dataToCopy),
                        widget.barcodeTitle);
                  },
                  icon: const Icon(Icons.qr_code)),
              IconButton(onPressed: onTap, icon: icon),
            ],
          )
        ],
      ),
    );
  }
}
