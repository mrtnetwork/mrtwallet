import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';

class ProgressWithTextView extends StatelessWidget {
  const ProgressWithTextView({super.key, required this.text, this.icon});
  final String text;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
      text: Text(text, textAlign: TextAlign.center),
      icon: icon,
    );
  }
}

class ErrorWithTextView extends StatelessWidget {
  const ErrorWithTextView({super.key, required this.text, this.progressKey});
  final String text;
  final GlobalKey<PageProgressBaseState>? progressKey;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            ConstraintsBoxView(
              maxHeight: 120,
              child: Container(
                padding: WidgetConstant.padding10,
                decoration: BoxDecoration(
                    borderRadius: WidgetConstant.border8,
                    color: context.colors.errorContainer),
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.onErrorContainer),
                  ),
                ),
              ),
            ),
            if (progressKey != null) ...[
              WidgetConstant.height20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                      onPressed: () {
                        progressKey?.backToIdle();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text("back_to_the_page".tr))
                ],
              )
            ],
          ],
        ),
        icon: WidgetConstant.errorIconLarge);
  }
}

class SuccessWithTextView extends StatelessWidget {
  const SuccessWithTextView({super.key, required this.text, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Text(text, textAlign: TextAlign.center),
        icon: icon != null
            ? Icon(icon, size: APPConst.double80)
            : WidgetConstant.checkCircleLarge);
  }
}

class SuccessBarcodeProgressView extends StatefulWidget {
  const SuccessBarcodeProgressView(
      {super.key,
      required this.text,
      required this.bottomWidget,
      this.secure = false,
      this.secureButtonText});
  final String text;
  final Widget bottomWidget;
  final bool secure;
  final String? secureButtonText;

  @override
  State<SuccessBarcodeProgressView> createState() =>
      _SuccessBarcodeProgressViewState();
}

class _SuccessBarcodeProgressViewState extends State<SuccessBarcodeProgressView>
    with SafeState {
  late bool isSecure = widget.secure;
  void onShowContent() {
    isSecure = !isSecure;
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            SecureContentView(
              show: !isSecure,
              showButtonTitle: widget.secureButtonText?.tr ?? "show_content".tr,
              onTapShow: onShowContent,
              widgetContent: ContainerWithBorder(
                  child: CopyTextIcon(
                      isSensitive: widget.secure,
                      dataToCopy: widget.text,
                      widget: Text(widget.text, maxLines: 3))),
            ),
            WidgetConstant.height8,
            widget.bottomWidget
          ],
        ),
        icon: WidgetConstant.checkCircleLarge);
  }
}

class SuccessWithButtonView extends StatelessWidget {
  const SuccessWithButtonView(
      {super.key,
      this.text,
      required this.buttonText,
      this.buttonWidget,
      required this.onPressed})
      : assert(text != null || buttonWidget != null,
            "use text or buttonWidget for child");
  final String? text;
  final String buttonText;
  final Widget? buttonWidget;
  final DynamicVoid onPressed;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            buttonWidget ?? Text(text!, textAlign: TextAlign.center),
            WidgetConstant.height8,
            FilledButton(onPressed: onPressed, child: Text(buttonText))
          ],
        ),
        icon: WidgetConstant.checkCircleLarge);
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

class SuccessTransactionTextView extends StatelessWidget {
  const SuccessTransactionTextView({
    super.key,
    required this.txId,
    required this.network,
  });
  final String txId;
  final WalletNetwork network;

  @override
  Widget build(BuildContext context) {
    final Widget successTrText = Column(
      children: [
        CircleTokenImgaeView(network.coinParam.token,
            radius: APPConst.double80),
        WidgetConstant.height20,
        WidgetConstant.checkCircle,
        Text(network.coinParam.token.name, style: context.textTheme.labelLarge),
        WidgetConstant.height20,
        ContainerWithBorder(
            child: CopyTextIcon(
                isSensitive: false,
                dataToCopy: txId,
                widget: OneLineTextWidget(txId))),
        WidgetConstant.height20,
        FilledButton.icon(
            onPressed: () {
              final addr = network.coinParam.getTransactionExplorer(txId);
              if (addr == null) return;
              UriUtils.lunch(addr);
            },
            icon: const Icon(Icons.open_in_browser),
            label: Text("view_on_explorer".tr)),
      ],
    );

    return _ProgressWithTextView(
        text: successTrText, icon: WidgetConstant.sizedBox);
  }
}
