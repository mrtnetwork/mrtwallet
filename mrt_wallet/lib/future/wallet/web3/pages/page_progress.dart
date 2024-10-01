import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/request/web_request.dart';

enum Web3ProgressStatus {
  progress(true),
  error(true),
  idle(true),
  successResponse(false),
  errorResponse(false),
  successRequest(false),
  failedRequest(false);

  final bool canUpdate;
  const Web3ProgressStatus(this.canUpdate);

  static Web3ProgressStatus fromWeb3Status(
      Web3RequestCompleterErrorType? status) {
    switch (status) {
      case Web3RequestCompleterErrorType.response:
        return Web3ProgressStatus.successResponse;
      case Web3RequestCompleterErrorType.error:
        return Web3ProgressStatus.errorResponse;
      case Web3RequestCompleterErrorType.closed:
        return Web3ProgressStatus.failedRequest;
      case Web3RequestCompleterErrorType.success:
        return Web3ProgressStatus.successRequest;
      default:
        return Web3ProgressStatus.idle;
    }
  }
}

class Web3PageProgress extends StatefulWidget {
  const Web3PageProgress(
      {super.key,
      required this.child,
      this.initialStatus = Web3ProgressStatus.idle,
      this.initialWidget});
  final Web3ProgressStatus initialStatus;
  final FuncWidgetContext child;
  final Widget? initialWidget;

  @override
  State<Web3PageProgress> createState() => Web3PageProgressState();
}

class Web3PageProgressState extends State<Web3PageProgress> with SafeState {
  late Web3ProgressStatus _status = widget.initialStatus;

  Widget? _responseWidget;
  bool _successResponse = false;
  Widget? _child;

  @override
  void dispose() {
    super.dispose();
    _child = null;
  }

  void _updateStream(Web3ProgressStatus status) {
    if (closed || !mounted) return;
    _status = status;
    setState(() {});
  }

  void _update(Web3ProgressStatus status, Widget? widget) {
    if (_status.canUpdate) {
      _responseWidget = widget;
      _updateStream(status);
    }
  }

  void response({String? text, Widget? widget}) {
    _update(
        Web3ProgressStatus.successResponse,
        widget ??
            ProgressWithTextView(
              text: text ?? "",
              icon: WidgetConstant.checkCircle,
            ));
    _successResponse = true;
  }

  void processs({String? text, Widget? widget}) {
    _update(Web3ProgressStatus.progress,
        widget ?? ProgressWithTextView(text: text ?? ""));
  }

  void error(
      {String? text,
      // Widget? widget,
      Duration? backToIdle = APPConst.twoSecoundDuration}) {
    _update(
        backToIdle == null
            ? Web3ProgressStatus.errorResponse
            : Web3ProgressStatus.error,
        ProgressWithTextView(
          text: text ?? "",
          icon: WidgetConstant.errorIconLarge,
        ));
    if (backToIdle != null) {
      Future.delayed(backToIdle, () => _update(Web3ProgressStatus.idle, null));
    }
  }

  void closedRequest() {
    _responseWidget ??= WidgetConstant.sizedBox;
    _updateStream(Web3ProgressStatus.failedRequest);
  }

  void successRequest() {
    _responseWidget ??= WidgetConstant.sizedBox;
    _updateStream(Web3ProgressStatus.successRequest);
  }

  void idle() {
    _update(Web3ProgressStatus.idle, null);
  }

  @override
  void didUpdateWidget(covariant Web3PageProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher<Web3ProgressStatus>(
      duration: APPConst.animationDuraion,
      enable: _status,
      widgets: {
        Web3ProgressStatus.idle: (c) => FutureBuilder(
              future: MethodUtils.after(() async => widget.child(c)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WidgetConstant.errorIcon,
                      Text(snapshot.error?.toString() ?? "")
                    ],
                  );
                }
                if (snapshot.hasData) {
                  _child = snapshot.data!;
                }
                return _child ?? WidgetConstant.sizedBox;
              },
            ),
        Web3ProgressStatus.progress: (c) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Padding(
                  padding: WidgetConstant.paddingHorizontal10,
                  child: _responseWidget ??
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                )),
              ],
            ),
        Web3ProgressStatus.error: (c) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Padding(
                  padding: WidgetConstant.paddingHorizontal10,
                  child: _responseWidget ??
                      Center(child: WidgetConstant.errorIconLarge),
                )),
              ],
            ),
        Web3ProgressStatus.errorResponse: (c) => _ProgressSuccessChildWidget(
              status: _status,
              successText: _responseWidget!,
              successResponse: _successResponse,
            ),
        Web3ProgressStatus.successResponse: (c) => _ProgressSuccessChildWidget(
              status: _status,
              successText: _responseWidget!,
              successResponse: _successResponse,
            ),
        Web3ProgressStatus.failedRequest: (c) => _ProgressSuccessChildWidget(
              status: _status,
              successText: _responseWidget!,
              successResponse: _successResponse,
            ),
        Web3ProgressStatus.successRequest: (c) => _ProgressSuccessChildWidget(
              status: _status,
              successText: _responseWidget!,
              successResponse: _successResponse,
            ),
      },
    );
  }
}

class _ProgressSuccessChildWidget extends StatelessWidget {
  const _ProgressSuccessChildWidget({
    required this.successText,
    required this.status,
    required this.successResponse,
    Key? key,
  }) : super(key: key);
  final Widget successText;
  final Web3ProgressStatus status;
  final bool successResponse;
  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.padding20,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              successText,
              WidgetConstant.height20,
              WidgetConstant.divider,
              _CompleteRequestStatusWidget(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteRequestStatusWidget extends StatelessWidget {
  const _CompleteRequestStatusWidget({required this.status, Key? key})
      : super(key: key);
  final Web3ProgressStatus status;
  @override
  Widget build(BuildContext context) {
    switch (status) {
      case Web3ProgressStatus.successResponse:
      case Web3ProgressStatus.errorResponse:
        return ProgressWithTextView(
          text: "web3_sending_response_to_client".tr,
        );
      case Web3ProgressStatus.failedRequest:
        return ProgressWithTextView(
          text: "web3_sending_response_error_desc".tr,
          icon: WidgetConstant.errorIcon,
        );

      default:
        return ProgressWithTextView(
            text: "web3_response_successfully_desc".tr,
            icon: WidgetConstant.checkCircle);
    }
  }
}

extension QuickAccsessWeb3PageProgressState
    on GlobalKey<Web3PageProgressState> {
  void idle() {
    currentState?.idle();
  }

  void response({String? text, Widget? widget}) {
    currentState?.response(text: text, widget: widget);
  }

  void responseTx({required String hash, required WalletNetwork network}) {
    currentState?.response(
        widget: SuccessTransactionTextView(txId: [hash], network: network));
  }

  void process({String? text}) {
    currentState?.processs(text: text);
  }

  void error(
      {Duration? backToIdle = APPConst.twoSecoundDuration, String? text}) {
    currentState?.error(text: text, backToIdle: backToIdle);
  }

  void closedRequest() {
    currentState?.closedRequest();
  }

  void successRequest() {
    currentState?.successRequest();
  }
}
