import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst, PlatformUtils;
import 'package:mrt_wallet/app/models/models/typedef.dart' show StringVoid;
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class PasteTextIcon extends StatefulWidget {
  const PasteTextIcon(
      {required this.onPaste,
      required this.isSensitive,
      super.key,
      this.size,
      this.color});
  final StringVoid onPaste;
  final double? size;
  final Color? color;
  final bool isSensitive;

  @override
  State<PasteTextIcon> createState() => PasteTextIconState();
}

class PasteTextIconState extends State<PasteTextIcon> with SafeState {
  bool inPaste = false;
  void onTap() async {
    if (inPaste) return;
    inPaste = true;
    setState(() {});
    try {
      final data = await PlatformUtils.readClipboard();
      if (!mounted) return;
      final String txt = data ?? "";
      if (txt.isEmpty) {
        // ignore: use_build_context_synchronously
        context.showAlert("clipboard_empty".tr);
        await Future.delayed(APPConst.milliseconds100);
        return;
      }
      widget.onPaste(txt);
      _resetClipoard(txt);
      await Future.delayed(APPConst.oneSecoundDuration);
    } finally {
      inPaste = false;
      setState(() {});
    }
  }

  void _resetClipoard(String txt) {
    if (!widget.isSensitive) return;
    MethodUtils.after(() async {
      final data = await PlatformUtils.readClipboard();
      if (data != txt) return;
      PlatformUtils.writeClipboard('');
    }, milliseconds: APPConst.tenSecoundDuration);
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      inPaste ? Icons.check_circle : Icons.paste,
      size: widget.size,
      key: ValueKey<bool>(inPaste),
      color: widget.color,
    );
    return IconButton(
      onPressed: onTap,
      icon: AnimatedSwitcher(duration: APPConst.animationDuraion, child: icon),
    );
  }
}
