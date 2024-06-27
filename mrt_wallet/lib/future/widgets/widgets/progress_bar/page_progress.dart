import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

typedef PageProgressStatus = StreamWidgetStatus;

class PageProgress extends StatefulWidget {
  const PageProgress({
    super.key,
    required this.child,
    this.initialStatus = PageProgressStatus.idle,
    this.backToIdle,
    this.initialWidget,
  }) : assert(initialStatus != PageProgressStatus.hide,
            "hide does not work in page progress");
  final PageProgressStatus initialStatus;
  final FuncWidget child;
  final Duration? backToIdle;
  final Widget? initialWidget;

  @override
  State<PageProgress> createState() => PageProgressState();
}

class PageProgressState extends State<PageProgress> with SafeState {
  late PageProgressStatus _status = widget.initialStatus;
  late Widget? _statusWidget = widget.initialWidget;

  PageProgressStatus get status => _status;

  void _listen(PageProgressStatus status) async {
    if (widget.backToIdle == null) return;
    if (status == PageProgressStatus.progress ||
        status == PageProgressStatus.idle ||
        status == PageProgressStatus.hide) return;
    await Future.delayed(widget.backToIdle ?? Duration.zero);
    updateStream(PageProgressStatus.idle, progressWidget: null);
  }

  @override
  void dispose() {
    super.dispose();
    _statusWidget = null;
  }

  void updateStream(PageProgressStatus status,
      {Widget? progressWidget, bool backToIdle = true}) {
    if (!mounted) return;
    _status = status;
    _statusWidget = progressWidget;
    if (backToIdle) {
      _listen(status);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: APPConst.animationDuraion,
      child: _status == PageProgressStatus.idle
          ? widget.child()
          : Row(
              children: [
                Expanded(
                  child: ConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      key: ValueKey(_status),
                      children: [
                        _status == StreamWidgetStatus.success
                            ? _statusWidget ?? WidgetConstant.checkCircleLarge
                            : _status == StreamWidgetStatus.error
                                ? _statusWidget ?? WidgetConstant.errorIconLarge
                                : _statusWidget ??
                                    const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
