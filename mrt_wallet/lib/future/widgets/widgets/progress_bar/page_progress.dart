import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

typedef PageProgressStatus = StreamWidgetStatus;

abstract class PageProgressBaseState<T extends StatefulWidget>
    extends State<T> {
  abstract PageProgressStatus _status;
  abstract Widget? _statusWidget;
  Widget? get statusWidget => _statusWidget;
  Duration? get backToIdle;

  PageProgressStatus get status => _status;

  void _listen(PageProgressStatus status) async {
    if (backToIdle == null) return;
    if (status == PageProgressStatus.progress ||
        status == PageProgressStatus.idle ||
        status == PageProgressStatus.hide) return;
    await Future.delayed(backToIdle ?? Duration.zero);
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
}

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

class PageProgressState extends PageProgressBaseState<PageProgress>
    with SafeState {
  @override
  late PageProgressStatus _status = widget.initialStatus;
  @override
  late Widget? _statusWidget = widget.initialWidget;
  @override
  Duration? get backToIdle => widget.backToIdle;

  @override
  void dispose() {
    super.dispose();
    _statusWidget = null;
  }

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher(
      duration: APPConst.animationDuraion,
      enable: _status,
      widgets: {
        PageProgressStatus.idle: (c) => widget.child(),
        PageProgressStatus.success: (c) => PageProgressChildWidget(
            _statusWidget ?? WidgetConstant.checkCircleLarge),
        PageProgressStatus.error: (c) => PageProgressChildWidget(
            _statusWidget ?? WidgetConstant.errorIconLarge),
        PageProgressStatus.progress: (c) => PageProgressChildWidget(
            _statusWidget ?? const CircularProgressIndicator()),
      },
    );
  }
}

class PageProgressChildWidget extends StatelessWidget {
  const PageProgressChildWidget(this.statusWidget, {Key? key})
      : super(key: key);
  final Widget statusWidget;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [statusWidget],
            ),
          ),
        ),
      ],
    );
  }
}

typedef FullPageAppBar = PreferredSizeWidget Function(
    BuildContext context, PageProgressStatus status);
typedef PageProgressContextWidget = Widget? Function(
    BuildContext context, PageProgressStatus status);

class FullPageProgressWidget extends StatefulWidget {
  const FullPageProgressWidget({
    super.key,
    required this.child,
    this.initialStatus = PageProgressStatus.idle,
    this.backToIdle,
    this.initialWidget,
    this.scaffoldKey,
    this.bottomNavigationBar,
    this.appBar,
  }) : assert(initialStatus != PageProgressStatus.hide,
            "hide does not work in page progress");
  final PageProgressStatus initialStatus;
  final FullPageAppBar? appBar;
  final FuncWidgetContext child;
  final Duration? backToIdle;
  final Widget? initialWidget;
  final Key? scaffoldKey;
  final PageProgressContextWidget? bottomNavigationBar;

  @override
  State<FullPageProgressWidget> createState() => FullPageProgressWidgetState();
}

class FullPageProgressWidgetState
    extends PageProgressBaseState<FullPageProgressWidget> with SafeState {
  @override
  late PageProgressStatus _status = widget.initialStatus;
  @override
  late Widget? _statusWidget = widget.initialWidget;
  @override
  Duration? get backToIdle => widget.backToIdle;

  @override
  void dispose() {
    super.dispose();
    _statusWidget = null;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffolPageView(
      appBar: widget.appBar?.call(context, _status),
      bottomNavigationBar: widget.bottomNavigationBar?.call(context, _status),
      scaffoldKey: widget.scaffoldKey,
      child: APPAnimatedSwitcher(
        duration: APPConst.animationDuraion,
        enable: _status,
        widgets: {
          PageProgressStatus.idle: (c) => widget.child(context),
          PageProgressStatus.success: (c) => PageProgressChildWidget(
              _statusWidget ?? WidgetConstant.checkCircleLarge),
          PageProgressStatus.error: (c) => PageProgressChildWidget(
              _statusWidget ?? WidgetConstant.errorIconLarge),
          PageProgressStatus.progress: (c) => PageProgressChildWidget(
              _statusWidget ?? const CircularProgressIndicator()),
        },
      ),
    );
  }
}
