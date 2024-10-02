import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/app/utils/platform/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/widgets/animated/widgets/animated_switcher.dart';
import 'barcode/widgets/barcode_view.dart';
import 'container_with_border.dart';
import 'text_widget.dart';
import 'widget_constant.dart';

enum _CopyTextStatus {
  idlle,
  pending,
  success,
  error;

  bool get isIdle => this == idlle;
}

mixin _CopyTextState<T extends StatefulWidget> on SafeState<T> {
  String get dataToCopy;
  String? get message;
  bool get isSensitive;
  _CopyTextStatus status = _CopyTextStatus.idlle;
  void onTap(BuildContext context) async {
    if (!status.isIdle) return;
    status = _CopyTextStatus.pending;
    updateState();
    final response = await PlatformUtils.writeClipboard(dataToCopy);
    if (response) {
      status = _CopyTextStatus.success;
      context.showAlert(message ?? "copied_to_clipboard".tr);
    } else {
      status = _CopyTextStatus.error;
      context.showAlert("copied_to_clipboard_faild".tr);
    }
    await Future.delayed(APPConst.oneSecoundDuration);
    status = _CopyTextStatus.idlle;
    updateState();
    if (!isSensitive) return;
    _resetClipoard(dataToCopy);
  }

  static void _resetClipoard(String txt) {
    MethodUtils.after(() async {
      final data = await PlatformUtils.readClipboard();
      if (data != txt) return;
      PlatformUtils.writeClipboard('');
    }, milliseconds: APPConst.tenSecoundDuration);
  }
}

class CopyTextIcon extends StatefulWidget {
  const CopyTextIcon(
      {super.key,
      required this.dataToCopy,
      this.widget,
      this.size,
      this.messaage,
      this.color,
      this.isSensitive = false});
  final String dataToCopy;
  final double? size;
  final String? messaage;
  final Color? color;
  final Widget? widget;
  final bool isSensitive;

  @override
  State<CopyTextIcon> createState() => CopyTextIconState();
}

class CopyTextIconState extends State<CopyTextIcon>
    with SafeState, _CopyTextState {
  @override
  String get dataToCopy => widget.dataToCopy;

  @override
  bool get isSensitive => widget.isSensitive;

  @override
  String? get message => widget.messaage;

  @override
  Widget build(BuildContext context) {
    final icon = IconButton(
      onPressed: () => onTap(context),
      icon: APPAnimatedSwitcher(enable: status, widgets: {
        _CopyTextStatus.idlle: (context) =>
            Icon(Icons.copy, size: widget.size, color: widget.color),
        _CopyTextStatus.pending: (context) => SizedBox(
            width: widget.size ?? APPConst.iconSize,
            height: widget.size ?? APPConst.iconSize,
            child: CircularProgressIndicator(color: widget.color)),
        _CopyTextStatus.success: (context) =>
            Icon(Icons.check_circle, size: widget.size, color: widget.color),
        _CopyTextStatus.error: (context) =>
            Icon(Icons.error, size: widget.size, color: context.colors.error)
      }),
    );
    return InkWell(
      onTap: () => onTap(context),
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
      this.buttons = const [],
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
  final List<Widget> buttons;
  final bool secureBarcode;

  @override
  State<CopyTextWithBarcode> createState() => CopyTextWithBarcodeState();
}

class CopyTextWithBarcodeState extends State<CopyTextWithBarcode>
    with SafeState, _CopyTextState {
  @override
  String get dataToCopy => widget.dataToCopy;

  @override
  bool get isSensitive => widget.secureBarcode;

  @override
  String? get message => widget.messaage;

  @override
  Widget build(BuildContext context) {
    final icon = IconButton(
      onPressed: () => onTap(context),
      icon: APPAnimatedSwitcher(enable: status, widgets: {
        _CopyTextStatus.idlle: (context) =>
            Icon(Icons.copy, size: widget.size, color: widget.color),
        _CopyTextStatus.pending: (context) => SizedBox(
            width: widget.size ?? APPConst.iconSize,
            height: widget.size ?? APPConst.iconSize,
            child: CircularProgressIndicator(color: widget.color)),
        _CopyTextStatus.success: (context) =>
            Icon(Icons.check_circle, size: widget.size, color: widget.color),
        _CopyTextStatus.error: (context) =>
            Icon(Icons.error, size: widget.size, color: context.colors.error)
      }),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.widget,
        WidgetConstant.width8,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...widget.buttons,
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
                                      isSensitive: widget.secureBarcode,
                                      widget: OneLineTextWidget(
                                          widget.dataToCopy,
                                          maxLine: 3))),
                          barcodeData: widget.dataToCopy),
                      widget.barcodeTitle);
                },
                icon: const Icon(Icons.qr_code)),
            icon,
          ],
        )
      ],
    );
  }
}
