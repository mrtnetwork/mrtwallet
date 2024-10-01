import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/typdef/typedef.dart';

class ToolTipView extends StatelessWidget {
  const ToolTipView(
      {super.key,
      this.message,
      this.boxDecoration,
      this.tooltipWidget,
      required this.child,
      this.toolTipKey,
      this.verticalOffset = 0,
      this.mode,
      this.onTriggered,
      this.duration = const Duration(seconds: 5),
      this.margin = const EdgeInsets.all(15),
      this.padding = const EdgeInsets.all(10),
      this.selectableTooltip = false,
      this.backgroundColor,
      this.waitDuration = const Duration(seconds: 2),
      this.textStyle});

  ToolTipView setKey(GlobalKey<TooltipState>? toolTipKey) {
    return ToolTipView(
      backgroundColor: backgroundColor,
      boxDecoration: boxDecoration,
      duration: duration,
      margin: margin,
      message: message,
      key: key,
      mode: mode,
      onTriggered: onTriggered,
      padding: padding,
      selectableTooltip: selectableTooltip,
      toolTipKey: toolTipKey,
      tooltipWidget: tooltipWidget,
      verticalOffset: verticalOffset,
      waitDuration: waitDuration,
      textStyle: textStyle,
      child: child,
    );
  }

  final String? message;
  final Widget child;
  final GlobalKey? toolTipKey;
  final double verticalOffset;
  final TooltipTriggerMode? mode;
  final Duration duration;
  final FuncWidgetContext? tooltipWidget;
  final void Function()? onTriggered;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool selectableTooltip;
  final Decoration? boxDecoration;
  final Duration? waitDuration;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    if (tooltipWidget == null && message == null) {
      return child;
    }
    final theme = Theme.of(context);
    return Tooltip(
      key: toolTipKey,
      waitDuration: waitDuration,
      enableFeedback: true,
      // textStyle: textStyle,
      richMessage: WidgetSpan(
          child: tooltipWidget?.call(context) ??
              Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    message!,
                    style: textStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer
                                .withOpacity(0.8)),
                  ))),
      margin: margin,
      padding: padding,
      verticalOffset: verticalOffset,
      onTriggered: onTriggered,
      showDuration: duration,
      triggerMode: mode,
      decoration: boxDecoration ??
          BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: backgroundColor ?? theme.colorScheme.tertiaryContainer),
      child: child,
    );
  }
}
