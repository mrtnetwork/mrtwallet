import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

class UpdateTokenDetailsView extends StatefulWidget {
  const UpdateTokenDetailsView({super.key, required this.token});
  final Token token;

  @override
  State<UpdateTokenDetailsView> createState() => _UpdateTokenDetailsViewState();
}

class _UpdateTokenDetailsViewState extends State<UpdateTokenDetailsView>
    with SafeState {
  final GlobalKey<AppTextFieldState> nameTextFieldKey =
      GlobalKey(debugLabel: "_UpdateTokenDetailsViewState_nameTextFieldKey");
  final GlobalKey<AppTextFieldState> symbolTextFieldKey =
      GlobalKey(debugLabel: "_UpdateTokenDetailsViewState_symbolTextFieldKey");
  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "_UpdateTokenDetailsViewState");
  late String tokenName = widget.token.name;
  late String tokenSymbol = widget.token.name;
  void onTokenNameChange(String v) {
    tokenName = v;
  }

  void onTokenSymbolChange(String v) {
    tokenSymbol = v;
  }

  String? tokenNamevalidator(String? v) {
    final val = v?.trim() ?? "";
    if (val.length < 3) {
      return "token_name_validator".tr;
    }
    return null;
  }

  void onPressed() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (context.mounted) {
      context.pop(widget.token.copyWith(name: tokenName, symbol: tokenSymbol));
    }
  }

  String? tokenSymbolvalidator(String? v) {
    final val = v?.trim() ?? "";
    if (val.length < 2) {
      return "token_symbol_validator".tr;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "update_token_information".tr,
              body: Text("update_token_desc".tr)),
          WidgetConstant.height20,
          AppTextField(
              label: "name".tr,
              minlines: 1,
              initialValue: tokenName,
              validator: tokenNamevalidator,
              onChanged: onTokenNameChange,
              key: nameTextFieldKey),
          WidgetConstant.height20,
          AppTextField(
              label: "symbol".tr,
              minlines: 1,
              initialValue: tokenName,
              validator: tokenSymbolvalidator,
              onChanged: onTokenSymbolChange,
              key: symbolTextFieldKey),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: onPressed,
                child: Text("update_token".tr),
              )
            ],
          )
        ],
      ),
    );
  }
}
