import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst;
import 'dart:ui' as ui;
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class LargeTextView extends StatefulWidget {
  const LargeTextView(this.text, {super.key, this.style, this.maxLine = 3});
  final List<String> text;
  final TextStyle? style;
  final int maxLine;
  @override
  State<LargeTextView> createState() => _LargeTextViewState();
}

class _LargeTextViewState extends State<LargeTextView> with SafeState {
  bool showMore = false;
  late final String text = widget.text.join("\n");
  void onTap() {
    showMore = !showMore;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: APPConst.animationDuraion,
      child: LayoutBuilder(
        key: ValueKey(showMore),
        builder: (context, constraints) {
          final span = TextSpan(
              text: text, style: widget.style ?? context.textTheme.bodyMedium);
          final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
          tp.layout(maxWidth: constraints.maxWidth);
          List<ui.LineMetrics> lines = tp.computeLineMetrics();
          if (lines.length > widget.maxLine && !showMore) {
            return InkWell(
              onTap: onTap,
              splashFactory: NoSplash.splashFactory,
              child: Wrap(
                alignment: WrapAlignment.end,
                runAlignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(text, maxLines: widget.maxLine),
                  // GestureDetector(
                  //   onTap: onTap,
                  //   child: ,
                  // ),
                  Text("read_more".tr,
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: context.colors.tertiary))
                ],
              ),
            );
          }
          return GestureDetector(
              onTap: lines.length > widget.maxLine ? onTap : null,
              child: Text(text));
        },
      ),
    );
  }
}
