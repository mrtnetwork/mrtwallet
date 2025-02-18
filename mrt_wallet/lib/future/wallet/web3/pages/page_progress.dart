import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';
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

class Web3PageProgressState extends State<Web3PageProgress>
    with SafeState<Web3PageProgress> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;
  late final Live<Web3ProgressStatus> _statusLive = Live(widget.initialStatus);
  Web3ProgressStatus get _status => _statusLive.value;
  Widget? _responseWidget;
  Widget? _child;

  void _shwoRequestStatus() async {
    final key = ScaffoldMessenger.maybeOf(context);
    controller ??= key?.showSnackBar(_requestStatusView(
      context: context,
      status: _statusLive,
      onHide: () {
        controller?.close();
        controller = null;
      },
    ));
  }

  void _updateStream(Web3ProgressStatus status) {
    _statusLive.value = status;
    updateState();
    if (!status.canUpdate) {
      _shwoRequestStatus();
    }
  }

  void _update({required Web3ProgressStatus status, Widget? widget}) {
    if (_status.canUpdate) {
      _responseWidget = widget;
      _updateStream(status);
    }
  }

  void response({String? text, Widget? widget}) {
    _update(
        status: Web3ProgressStatus.successResponse,
        widget: widget ??
            PageProgressChildWidget(ProgressWithTextView(
                text: text ?? "", icon: WidgetConstant.checkCircleLarge)));
  }

  void processs({String? text}) {
    _update(
        status: Web3ProgressStatus.progress,
        widget:
            PageProgressChildWidget(ProgressWithTextView(text: text ?? "")));
  }

  void _error(
      {String? text,
      Widget? widget,
      Duration? backToIdle = APPConst.twoSecoundDuration,
      required Web3ProgressStatus status}) {
    _update(
        status: status,
        widget: widget ??
            PageProgressChildWidget(ProgressWithTextView(
                text: text ?? "", icon: WidgetConstant.errorIconLarge)));
    if (backToIdle != null) {
      Future.delayed(
          backToIdle, () => _update(status: Web3ProgressStatus.idle));
    }
  }

  void closedRequest() {
    if (_responseWidget == null || _status == Web3ProgressStatus.progress) {
      _responseWidget = PageProgressChildWidget(ProgressWithTextView(
          text: "client_closed_durning_request".tr,
          icon: WidgetConstant.errorIconLarge));
    }

    _updateStream(Web3ProgressStatus.failedRequest);
  }

  void successRequest() {
    if (_responseWidget == null || _status == Web3ProgressStatus.progress) {
      _responseWidget = PageProgressChildWidget(ProgressWithTextView(
          text: "web3_response_successfully_desc".tr,
          icon: WidgetConstant.checkCircleLarge));
    }
    _updateStream(Web3ProgressStatus.successRequest);
  }

  void idle() {
    _update(status: Web3ProgressStatus.idle);
  }

  @override
  void didUpdateWidget(covariant Web3PageProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void safeDispose() {
    super.safeDispose();
    _child = null;
    controller?.close();
    _statusLive.dispose();
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
        Web3ProgressStatus.progress: (c) => _responseWidget,
        Web3ProgressStatus.error: (c) => _responseWidget,
        Web3ProgressStatus.errorResponse: (c) => _responseWidget,
        Web3ProgressStatus.successResponse: (c) => _responseWidget,
        Web3ProgressStatus.failedRequest: (c) => _responseWidget,
        Web3ProgressStatus.successRequest: (c) => _responseWidget
      },
    );
  }
}

SnackBar _requestStatusView(
    {required BuildContext context,
    required Live<Web3ProgressStatus> status,
    required DynamicVoid onHide}) {
  return SnackBar(
      duration: switch (status.value) {
        Web3ProgressStatus.successRequest => APPConst.tenSecoundDuration,
        Web3ProgressStatus.failedRequest => APPConst.tenSecoundDuration,
        _ => const Duration(minutes: 10)
      },
      action: SnackBarAction(label: 'close'.tr, onPressed: onHide),
      content: Row(
        children: [
          LiveWidget(() {
            switch (status.value) {
              case Web3ProgressStatus.successResponse:
              case Web3ProgressStatus.errorResponse:
                return APPCircularProgressIndicator(
                    color: context.colors.onInverseSurface);
              case Web3ProgressStatus.failedRequest:
                return Icon(Icons.error,
                    color: context.colors.onInverseSurface);
              default:
                return Icon(Icons.check_circle,
                    color: context.colors.onInverseSurface);
            }
          }),
          WidgetConstant.width8,
          Flexible(child: LiveWidget(() {
            switch (status.value) {
              case Web3ProgressStatus.successResponse:
              case Web3ProgressStatus.errorResponse:
                return OneLineTextWidget(
                    maxLine: 2,
                    "web3_sending_response_to_client".tr,
                    style: context.textTheme.labelLarge
                        ?.copyWith(color: context.colors.onInverseSurface));
              case Web3ProgressStatus.failedRequest:
                return OneLineTextWidget(
                    maxLine: 2,
                    "web3_sending_response_error_desc".tr,
                    style: context.textTheme.labelLarge
                        ?.copyWith(color: context.colors.onInverseSurface));
              default:
                return OneLineTextWidget(
                    maxLine: 2,
                    "web3_response_successfully_desc".tr,
                    style: context.textTheme.labelLarge
                        ?.copyWith(color: context.colors.onInverseSurface));
            }
          })),
        ],
      ));
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
        widget:
            Web3SuccessTransactionTextView(txIds: [hash], network: network));
  }

  void process({String? text}) {
    currentState?.processs(text: text);
  }

  void error({
    Object? error,
    String? message,
    Duration backToIdle = APPConst.twoSecoundDuration,
    bool showBackButton = false,
  }) {
    _errorResponseFromException(
        status: Web3ProgressStatus.error,
        showBackButton: showBackButton,
        backToIdle: backToIdle,
        error: error,
        message: message);
  }

  void errorResponse({Object? error, String? message}) {
    _errorResponseFromException(
        status: Web3ProgressStatus.errorResponse,
        error: error,
        message: message);
  }

  void _errorResponseFromException(
      {Object? error,
      String? message,
      Duration? backToIdle = APPConst.twoSecoundDuration,
      bool showBackButton = false,
      required Web3ProgressStatus status}) {
    showBackButton = showBackButton && status.canUpdate;
    if (error == WalletExceptionConst.rejectSigning) {
      showBackButton = false;
      backToIdle = APPConst.oneSecoundDuration;
    }
    if (showBackButton) {
      backToIdle = null;
    }
    final key = showBackButton ? this : null;
    if (error is WalletException) {
      currentState?._error(
          widget: _Web3ErrorMessageView(null, key, message: error.message.tr),
          backToIdle: backToIdle,
          status: status);
    } else if (error is Web3RequestException) {
      currentState?._error(
          backToIdle: backToIdle,
          widget: _Web3ErrorMessageView(error.message, key),
          status: status);
    } else if (error is ApiProviderException) {
      currentState?._error(
          backToIdle: backToIdle,
          widget: _Web3ErrorMessageView(error.message.toString(), key),
          status: status);
    } else if (error is BlockchainUtilsException) {
      currentState?._error(
          backToIdle: backToIdle,
          widget: _Web3ErrorMessageView(error.message, key),
          status: status);
    } else {
      currentState?._error(
          widget: _Web3ErrorMessageView(null, key, message: message),
          backToIdle: backToIdle,
          status: status);
    }
  }

  void closedRequest() {
    currentState?.closedRequest();
  }

  void successRequest() {
    currentState?.successRequest();
  }
}

class _Web3ErrorMessageView extends StatelessWidget {
  const _Web3ErrorMessageView(this.error, this.progressKey, {this.message});
  final String? message;
  final String? error;
  final GlobalKey<Web3PageProgressState>? progressKey;

  @override
  Widget build(BuildContext context) {
    return PageProgressChildWidget(_Web3ProgressWithTextView(
      progressKey: progressKey,
      text: message ?? "request_error".tr,
      icon: WidgetConstant.errorIconLarge,
      bottomWidget: error == null
          ? null
          : ContainerWithBorder(
              onRemove: () {},
              enableTap: false,
              onRemoveIcon:
                  Icon(Icons.error, color: context.onPrimaryContainer),
              child: SelectableText(error!,
                  minLines: 1,
                  maxLines: 3,
                  style: context.onPrimaryTextTheme.bodyMedium)),
    ));
  }
}

class _Web3ProgressWithTextView extends StatelessWidget {
  const _Web3ProgressWithTextView(
      {required this.text,
      required this.progressKey,
      this.icon,
      this.bottomWidget});
  final String text;
  final Widget? icon;
  final Widget? bottomWidget;
  final GlobalKey<Web3PageProgressState>? progressKey;

  @override
  Widget build(BuildContext context) {
    final canUpdate = progressKey?.currentState?._status.canUpdate ?? false;
    return _ProgressWithTextView(
        text: Column(
          children: [
            LargeTextView([text], maxLine: 3, textAligen: TextAlign.center),
            if (bottomWidget != null) bottomWidget!,
            if (canUpdate) ...[
              WidgetConstant.height20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                      onPressed: () {
                        progressKey?.idle();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text("back_to_the_page".tr))
                ],
              )
            ]
          ],
        ),
        icon: icon);
  }
}

class _ProgressWithTextView extends StatelessWidget {
  const _ProgressWithTextView({required this.text, this.icon});
  final Widget text;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon ?? const CircularProgressIndicator(),
        WidgetConstant.height8,
        text
      ],
    );
  }
}
