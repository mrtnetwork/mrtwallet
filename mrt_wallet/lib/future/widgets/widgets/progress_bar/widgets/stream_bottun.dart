import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

enum StreamWidgetStatus {
  idle,
  success,
  error,
  progress,
  hide;

  bool get inProgress => this == StreamWidgetStatus.progress;
}

class StreamWidget extends StatefulWidget {
  const StreamWidget({
    GlobalKey<StreamWidgetState>? key,
    required this.buttonWidget,
    this.padding = EdgeInsets.zero,
    this.initialStatus = StreamWidgetStatus.idle,
    this.backToIdle,
    this.hideAfterError = false,
    this.hideAfterSuccsess = false,
    this.fixedSize = true,
  }) : super(key: key);
  final StreamWidgetStatus initialStatus;
  final EdgeInsets padding;
  final Duration? backToIdle;
  final Widget buttonWidget;
  final bool hideAfterError;
  final bool hideAfterSuccsess;
  final bool fixedSize;

  @override
  State<StreamWidget> createState() => StreamWidgetState();
}

class StreamWidgetState extends State<StreamWidget> with SafeState {
  late StreamWidgetStatus _status = widget.initialStatus;
  @override
  void initState() {
    super.initState();
  }

  void _listen(StreamWidgetStatus status) async {
    if (status == StreamWidgetStatus.progress ||
        status == StreamWidgetStatus.idle ||
        status == StreamWidgetStatus.hide) return;
    if (widget.backToIdle == null) return;
    await Future.delayed(widget.backToIdle ?? Duration.zero);
    if (widget.hideAfterError && status == StreamWidgetStatus.error) {
      updateStream(StreamWidgetStatus.hide);
    } else if (widget.hideAfterSuccsess &&
        status == StreamWidgetStatus.success) {
      updateStream(StreamWidgetStatus.hide);
    } else {
      updateStream(StreamWidgetStatus.idle);
    }
  }

  void updateStream(StreamWidgetStatus status) {
    if (!mounted) return;
    _status = status;
    _listen(status);
    setState(() {});
  }

  bool get isProgress => _status == StreamWidgetStatus.progress;
  Size? size;
  void onChangeSize(Size widgetSize) {
    if (!widget.fixedSize) return;
    if (size != widgetSize && _status == StreamWidgetStatus.idle) {
      size = widgetSize;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: AnimatedSwitcher(
        duration: APPConst.animationDuraion,
        child: MeasureSize(
          onChange: onChangeSize,
          key: ValueKey(_status),
          child: SizedBox.fromSize(
            size: size,
            child: _status == StreamWidgetStatus.hide
                ? WidgetConstant.sizedBox
                : _status == StreamWidgetStatus.success
                    ? WidgetConstant.checkCircle
                    : _status == StreamWidgetStatus.error
                        ? WidgetConstant.errorIcon
                        : _status == StreamWidgetStatus.progress
                            ? const Center(child: CircularProgressIndicator())
                            : widget.buttonWidget,
          ),
        ),
      ),
    );
  }
}
