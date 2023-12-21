import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

class ProgressWithTextView extends StatelessWidget {
  const ProgressWithTextView({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(text: Text(text, textAlign: TextAlign.center));
  }
}

class ErrorWithTextView extends StatelessWidget {
  const ErrorWithTextView({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Text(text, textAlign: TextAlign.center),
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
            ? Icon(icon, size: AppGlobalConst.double80)
            : WidgetConstant.checkCircleLarge);
  }
}

class SuccessWithButtomView extends StatelessWidget {
  const SuccessWithButtomView(
      {super.key,
      required this.text,
      required this.buttomText,
      required this.onPressed});
  final String text;
  final String buttomText;
  final DynamicVoid onPressed;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            Text(text, textAlign: TextAlign.center),
            WidgetConstant.height8,
            FilledButton(onPressed: onPressed, child: Text(buttomText))
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
  final AppNetworkImpl network;

  @override
  Widget build(BuildContext context) {
    final Widget successTrText = Column(
      children: [
        CircleAssetsImgaeView(network.coinParam.logo,
            radius: AppGlobalConst.double80),
        WidgetConstant.height20,
        WidgetConstant.checkCircle,
        Text(network.coinParam.token.name, style: context.textTheme.labelLarge),
        WidgetConstant.height20,
        ContainerWithBorder(
            child: CopyTextIcon(
                dataToCopy: txId, widget: OneLineTextWidget(txId))),
        WidgetConstant.height20,
        FilledButton.icon(
            onPressed: () {
              LunchUri.lunch(network.coinParam.getTransactionExplorer(txId));
            },
            icon: const Icon(Icons.open_in_browser),
            label: Text("view_on_explorer".tr)),
      ],
    );

    return _ProgressWithTextView(
        text: successTrText, icon: WidgetConstant.sizedBox);
  }
}
