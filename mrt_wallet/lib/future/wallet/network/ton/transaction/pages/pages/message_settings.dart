import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/utils/ton/ton.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/networks/ton/ton.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TonTransactionMessageSettingsView extends StatefulWidget {
  const TonTransactionMessageSettingsView(this.receiver, {super.key});
  final TonOutputWithBalance receiver;

  @override
  State<TonTransactionMessageSettingsView> createState() =>
      _TonTransactionMessageSettingsViewState();
}

class _TonTransactionMessageSettingsViewState
    extends State<TonTransactionMessageSettingsView> {
  late bool isBounce = widget.receiver.bounce;
  late TonMessageBodyType bodyType = widget.receiver.bodyType;
  final GlobalKey<AppTextFieldState> bodyTextController =
      GlobalKey(debugLabel: "_TonTransactionMessageSettingsViewState");
  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "_TonTransactionMessageSettingsViewState_1");
  void toggleBounce() {
    setState(() {
      isBounce = !isBounce;
    });
  }

  void onChageBodyType(TonMessageBodyType? type) {
    if (type == TonMessageBodyType.encryptedMessage) return;
    setState(() {
      bodyType = type ?? bodyType;
    });
  }

  String? bodyForm(String? v) {
    if (bodyType == TonMessageBodyType.none) return null;
    if (bodyType.isValid(v)) return null;
    switch (bodyType) {
      case TonMessageBodyType.binaryComment:
        return "invalid_hex_bytes_string".tr;
      case TonMessageBodyType.comment:
        return "ton_message_body_comment_validator".tr;
      default:
        return "ton_invalid_cell_string_data".tr;
    }
  }

  void onPaste(String text) {
    bodyTextController.currentState?.updateText(text);
  }

  void submit() {
    if (formKey.currentState?.validate() ?? false) {
      final body = bodyTextController.currentState?.getValue();
      if (widget.receiver.setBody(bodyType, body)) {
        widget.receiver.toggleBounce(isBounce);
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.paddingHorizontal20,
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleSubtitle(
              title: "message_options".tr,
              body: Column(
                children: [
                  TextAndLinkView(
                    text: "body_message_desc".tr,
                    url: LinkConst.tonMessageBodyReview,
                    linkDesc: "read_more".tr,
                  ),
                  WidgetConstant.height8,
                  TextAndLinkView(
                    text: "ton_bounce_desc".tr,
                    url: LinkConst.tonBouncableReview,
                    linkDesc: "read_more".tr,
                  )
                ],
              ),
            ),
            AppSwitchListTile(
              title: Text(
                "bounce".tr,
                style: context.textTheme.titleMedium,
              ),
              contentPadding: EdgeInsets.zero,
              subtitle: Text("ton_bounce_desc2".tr),
              value: isBounce,
              onChanged: (p0) => toggleBounce(),
            ),
            WidgetConstant.height20,
            Text("type_of_message_body".tr,
                style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            AppDropDownBottom(
              items: {
                for (final i in TonMessageBodyType.supportValues)
                  i: Text(i.name.tr)
              },
              label: "choose_the_type".tr,
              onChanged: onChageBodyType,
              value: bodyType,
            ),
            APPAnimatedSize(
                isActive: bodyType.hasBody,
                onActive: (c) => _TonBodyBuilderView(
                      state: this,
                      initialValue: widget.receiver.body,
                    ),
                onDeactive: (c) => WidgetConstant.sizedBox),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                    padding: WidgetConstant.paddingVertical20,
                    onPressed: submit,
                    child: Text("update_messsage".tr))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// The body of the message

class _TonBodyBuilderView extends StatelessWidget {
  const _TonBodyBuilderView({required this.state, this.initialValue});
  final _TonTransactionMessageSettingsViewState state;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text(state.bodyType.name.tr, style: context.textTheme.titleMedium),
        Text(state.bodyType.helperText.tr),
        WidgetConstant.height8,
        AppTextField(
          key: state.bodyTextController,
          validator: state.bodyForm,
          label: "message_body".tr,
          minlines: 5,
          maxLines: 8,
          initialValue: initialValue,
          prefixIcon: PasteTextIcon(
            onPaste: state.onPaste,
            isSensitive: false,
          ),
          helperText: state.bodyType.helperText.tr,
        )
      ],
    );
  }
}
