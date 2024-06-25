import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';

class UpdateTokenDetailsView extends StatefulWidget {
  const UpdateTokenDetailsView(
      {super.key, required this.token, required this.account});
  final TokenCore token;
  final CryptoAccountAddress account;

  @override
  State<UpdateTokenDetailsView> createState() => _UpdateTokenDetailsViewState();
}

class _UpdateTokenDetailsViewState extends State<UpdateTokenDetailsView>
    with SafeState {
  final GlobalKey<AppTextFieldState> nameTextFieldKey =
      GlobalKey(debugLabel: "_UpdateTokenDetailsViewState_nameTextFieldKey");
  final GlobalKey<AppTextFieldState> symbolTextFieldKey =
      GlobalKey(debugLabel: "_UpdateTokenDetailsViewState_symbolTextFieldKey");
  final GlobalKey<AppTextFieldState> apiIdTextField =
      GlobalKey(debugLabel: "_UpdateTokenDetailsViewState_apiIdTextField");

  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "_UpdateTokenDetailsViewState");
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();
  Token get token => widget.token.token;
  late String tokenName = token.name;
  late String tokenSymbol = token.symbol;
  late String apiId = token.market?.apiId ?? "";
  late int decimal = token.decimal ?? 0;
  bool get canChangeDecimal => token.decimal != null;

  String? onValidateDecimal(String? v) {
    if (token.decimal == null) return "";
    final parse = int.tryParse(v ?? "");
    if (parse == null ||
        parse < 0 ||
        parse > BlockchainConstant.maxTokenDecimal) {
      return "token_decimals_validator".tr;
    }
    return null;
  }

  void onChangeDicmal(String? v) {
    decimal = int.tryParse(v ?? "") ?? 0;
  }

  void onChangeApiId(String v) {
    apiId = v;
  }

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

  String? tokenSymbolvalidator(String? v) {
    final val = v?.trim() ?? "";
    if (val.length < 2) {
      return "token_symbol_validator".tr;
    }
    return null;
  }

  String? apiIdValidator(String? v) {
    if (v?.isEmpty ?? true) return null;
    if (v!.length < 2) {
      return "coingecko_api_id_validator".tr;
    }
    return null;
  }

  void onUpdate() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final apiId = apiIdTextField.currentState!.getValue();
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    int? currectDecimal = token.decimal;
    if (token.hasDecimal && currectDecimal != decimal) {
      currectDecimal = decimal;
      final alert = await context.openSliverDialog(
          (ctx) => DialogTextView(
                buttomWidget: AsyncDialogDoubleButtonView(
                  firstButtonLabel: "change_decimals".tr,
                ),
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("change_token_decimal_desc".tr),
                    WidgetConstant.height8,
                    Text(
                      "change_token_decimal_desc2"
                          .tr
                          .replaceOne(token.decimal!.toString())
                          .replaceTwo(currectDecimal!.toString()),
                      style: context.textTheme.titleLarge,
                    )
                  ],
                ),
              ),
          "token_decimals".tr);
      if (alert != true) return;
    }
    CoingeckoCoin? market = token.market;
    if (apiId.isNotEmpty) {
      if (apiId != widget.token.token.market?.apiId) {
        progressKey.progressText("retrieving_token_price".tr);
        final result = await MethodCaller.call(() async {
          return await wallet.getCoinPrice(apiId);
        });
        if (result.hasError || result.result == null) {
          progressKey.errorText(result.error?.tr ?? "invalid_api_id".tr,
              backToIdle: true);
          return;
        }
        market = CoingeckoCoin(apiId: result.result!.id);
      }
    } else {
      market = null;
    }
    progressKey.progressText("updating_token".tr);
    final update = await wallet.updateToken(
        token: widget.token,
        updatedToken: Token(
          name: tokenName,
          symbol: tokenSymbol,
          decimal: currectDecimal,
          market: market,
          assetLogo: token.assetLogo,
        ),
        address: widget.account);
    if (update.hasError) {
      progressKey.errorText(update.error!);
      return;
    }
    progressKey.successText("token_updated_successfully".tr, backToIdle: false);
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: AppGlobalConst.oneSecoundDuration,
      initialStatus: StreamWidgetStatus.idle,
      initialWidget:
          ProgressWithTextView(text: "retrieving_token_information".tr),
      child: () => Form(
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
            Text("live_price".tr, style: context.textTheme.titleMedium),
            Text("coin_gecko_desc".tr),
            WidgetConstant.height8,
            AppTextField(
              label: "api_id".tr,
              key: apiIdTextField,
              validator: apiIdValidator,
              onChanged: onChangeApiId,
              initialValue: apiId,
            ),
            WidgetConstant.height20,
            if (canChangeDecimal) ...[
              Text("token_decimals".tr, style: context.textTheme.titleMedium),
              Text("change_token_decimal_desc".tr),
              WidgetConstant.height8,
              NumberTextField(
                  label: "decimals".tr,
                  validator: onValidateDecimal,
                  onChange: onChangeDicmal,
                  defaultValue: decimal,
                  max: BlockchainConstant.maxTokenDecimal,
                  min: 0),
            ],
            // AppDropDownBottom(
            //     onChanged: (p0) {},
            //     isExpanded: true,
            //     items: {for (final i in coins!.coins) i: Text(i.coinName)},
            //     label: "coingecko_id".tr),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: onUpdate,
                  child: Text("update_token".tr),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
