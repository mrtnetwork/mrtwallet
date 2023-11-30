import 'package:flutter/material.dart';

class ToolTipView extends StatelessWidget {
  const ToolTipView(
      {super.key,
      this.message,
      this.boxDecoration,
      this.tooltipWidget,
      required this.child,
      this.toolTipKey,
      this.verticalOffset = 0,
      this.mode = TooltipTriggerMode.tap,
      this.onTriggered,
      this.duration = const Duration(seconds: 5),
      this.margin = const EdgeInsets.all(15),
      this.padding = const EdgeInsets.all(10),
      this.selectableTooltip = false,
      this.backgroundColor});
  final String? message;
  final Widget child;
  final GlobalKey? toolTipKey;
  final double verticalOffset;
  final TooltipTriggerMode mode;
  final Duration duration;
  final Widget? tooltipWidget;
  final void Function()? onTriggered;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool selectableTooltip;
  final Decoration? boxDecoration;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    if (tooltipWidget == null && message == null) {
      return child;
    }
    final theme = Theme.of(context);
    return Tooltip(
      key: toolTipKey,
      waitDuration: const Duration(seconds: 2),
      richMessage: WidgetSpan(
          child: tooltipWidget ??
              Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiary.withOpacity(0.8)),
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
              color: backgroundColor ?? theme.colorScheme.tertiary),
      child: child,
    );
  }
}
