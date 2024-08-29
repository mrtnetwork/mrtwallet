import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';

import 'package:mrt_wallet/future/wallet/network/ripple/transaction/pages/pages/build_currency_amount.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class RippleGlobalTransactionFieldsView extends StatelessWidget {
  const RippleGlobalTransactionFieldsView(
      {required this.field,
      required this.account,
      required this.address,
      required this.validator,
      super.key});
  final TransactionFormField field;
  final ChainAccount address;
  final RippleChain account;
  final RippleTransactionForm validator;
  @override
  Widget build(BuildContext context) {
    switch (field.id) {
      case "burn_token_id":
      case "offer_token_id":
      case "accept_offer_sell_offer":
      case "accept_offer_buy_offer":
        return ContainerWithBorder(
          validate: field.isCompleted,
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  validator.validatorName.tr,
                  child: StringWriterView(
                    defaultValue: field.value,
                    maxLength: RippleConst.rippleTranactionHashLength,
                    minLength: RippleConst.rippleTranactionHashLength,
                    title: PageTitleSubtitle(
                        title: field.name.tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.subject!.tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: field.name.tr,
                  ),
                )
                .then(
                  (value) => validator.setValue(field, value),
                );
          },
          onRemoveIcon:
              field.hasValue ? const Icon(Icons.edit) : const Icon(Icons.add),
          child: Text(field.value ?? "tap_to_input_value".tr, maxLines: 3),
        );
      case "burn_owner":
      case "offer_owner":
      case "offer_destination":
      case "mint_issuer":
      case "escrow_create_destination":
      case "escrow_finish_owner":
      case "regular_key":
        return ReceiptAddressView(
          address: field.value,
          validate: field.isCompleted,
          title: null,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<XRPAddress>>(
                  validator.validatorName.tr,
                  maxExtend: 1,
                  minExtent: 0.8,
                  initialExtend: 0.9,
                  bodyBuilder: (c) => SelectRecipientAccountView<XRPAddress>(
                    account: account,
                    scrollController: c,
                    subtitle: PageTitleSubtitle(
                        title: field.name.tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.subject!.tr),
                          ],
                        )),
                  ),
                )
                .then((value) => validator.setValue(field, value));
          },
        );
      case "mint_nftokentaxon":
        return ContainerWithBorder(
          validate: field.isCompleted,
          onRemoveIcon:
              field.hasValue ? const Icon(Icons.edit) : const Icon(Icons.add),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
                  validator.validatorName.tr,
                  child: NumberWriteView(
                    defaultValue: field.value,
                    max: RippleConst.max32UnsignedRational,
                    allowDecimal: false,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: field.name.tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.subject!.tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: field.name.tr,
                  ),
                )
                .then((value) => validator.setValue(field, value));
          },
          child: Text(
              field.value?.toString().to3Digits ?? "tap_to_input_value".tr),
        );
      case "mint_transfer_fee":
      case "escrow_create_destination_tag":
      case "escrow_finish_sequence":
      case "trust_set_quality_in":
      case "trust_set_quality_out":
        return ContainerWithBorder(
          onRemoveIcon:
              field.hasValue ? const Icon(Icons.edit) : const Icon(Icons.add),
          validate: field.isCompleted,
          onRemove: () {
            BigRational? max;
            switch (field.id) {
              case "mint_transfer_fee":
                max = RippleConst.maxNftTokenTransferRate;
              case "escrow_create_destination_tag":
              case "trust_set_quality_in":
              case "trust_set_quality_out":
                max = RippleConst.max32UnsignedRational;
                break;
              default:
            }
            context
                .openSliverBottomSheet<BigRational>(
                  validator.validatorName.tr,
                  child: NumberWriteView(
                    defaultValue: field.value,
                    max: max,
                    allowDecimal: false,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: field.name.tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.subject!.tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: field.name.tr,
                  ),
                )
                .then((value) => validator.setValue(field, value));
          },
          child: Text(
              field.value?.toString().to3Digits ?? "tap_to_input_value".tr),
        );
      case "mint_uri":
      case "escrow_create_condition":
      case "escrow_finish_fulfillment":
        return ContainerWithBorder(
          onRemove: () {
            int? maxLength;
            if (field.id == "mint_uri") {
              maxLength = RippleConst.maxDomainLength;
            }
            context
                .openSliverBottomSheet<String>(
                  validator.validatorName.tr,
                  child: StringWriterView(
                    defaultValue: field.value,
                    maxLength: maxLength,
                    title: PageTitleSubtitle(
                        title: field.name.tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.subject!.tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: field.name.tr,
                  ),
                )
                .then(
                  (value) => validator.setValue(field, value),
                );
          },
          onRemoveIcon:
              field.hasValue ? const Icon(Icons.edit) : const Icon(Icons.add),
          child: validator.transactionType != XRPLTransactionType.escrowCreate
              ? Text(field.value ?? "tap_to_input_value".tr, maxLines: 3)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Expanded(
                          child: Text(field.value ?? "tap_to_input_value".tr,
                              maxLines: 3)),
                      if (!field.hasValue) ...[
                        WidgetConstant.width8,
                        FilledButton(
                          onPressed: () {
                            context
                                .openSliverDialog<String>(
                                    (p0) => const _GenerateFulFillmentView(),
                                    "fulfillment".tr)
                                .then((value) {
                              validator.setValue(field, value);
                            });
                          },
                          child: Text("generate".tr),
                        )
                      ],
                    ]),
        );
      case "mint_flag":
        return AppDropDownBottom(
          items: <NFTokenMintFlag, Widget>{
            for (var i in NFTokenMintFlag.values) i: Text(i.name)
          },
          label: field.name.tr,
          value: field.value,
          key: ValueKey<String>("set_${field.value}"),
          onChanged: (p0) => validator.setValue(field, p0),
          suffixIcon: field.hasValue
              ? IconButton(
                  onPressed: () {
                    validator.setValue(field, null);
                  },
                  icon: const Icon(Icons.remove_circle))
              : null,
        );
      case "offer_expiration":
      case "escrow_create_cancel_after":
        return ContainerWithBorder(
          onRemove: () {
            showAdaptiveDialog<DateTime>(
              context: context,
              useRootNavigator: false,
              builder: (context) {
                return DatePickerDialog(
                  firstDate: DateTime.now(),
                  lastDate: DateTime(3000),
                  fieldLabelText: field.name.tr,
                );
              },
            ).then((date) {
              if (date == null) {
                validator.setValue(field, null);
                return;
              }
              showAdaptiveDialog<TimeOfDay>(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  return TimePickerDialog(
                    initialTime: TimeOfDay.now(),
                    helpText: date.toOnlyDateStr(),
                  );
                },
              ).then((time) {
                if (time == null) {
                  validator.setValue(field, null);
                  return;
                }
                final DateTime picked = DateTime(
                    date.year, date.month, date.day, time.hour, time.minute);
                validator.setValue(field, picked);
              });
            });
          },
          onRemoveIcon:
              field.hasValue ? const Icon(Icons.edit) : const Icon(Icons.add),
          child: Text((field.value as DateTime?)?.toDateAndTime() ??
              "tap_to_input_value".tr),
        );

      case "offer_amount":
      case "accept_nft_broker_fee":
      case "trust_set_limit_amount":
        final XRPCurrencyAmount? value = field.value;
        return ContainerWithBorder(
          validate: field.isCompleted,
          onRemoveIcon:
              field.hasValue ? const Icon(Icons.edit) : const Icon(Icons.add),
          onRemove: () {
            context
                .openSliverBottomSheet<XRPCurrencyAmount>(
                  "setup_currency_amount".tr,
                  bodyBuilder: (controller) => BuildRippleCurrencyAmountView(
                    account: account,
                    scrollController: controller,
                    title: validator.validatorName.tr,
                    acceptZero: true,
                    supportXRP: field.id != "trust_set_limit_amount",
                  ),
                  minExtent: 0.6,
                  maxExtend: 1,
                  initialExtend: 0.7,
                )
                .then((value) => validator.setValue(field, value));
          },
          child: value == null
              ? Text("tap_to_input_value".tr)
              : CoinPriceView(
                  token: value.token,
                  balance: value.price,
                  style: context.textTheme.titleLarge,
                ),
        );
      case "nft_offer_flag":
        return AppDropDownBottom(
          items: <NftTokenCreateOfferFlag, Widget>{
            for (var i in NftTokenCreateOfferFlag.values) i: Text(i.name)
          },
          label: field.name.tr,
          value: field.value,
          key: ValueKey<String>("set_${field.value}"),
          onChanged: (p0) => validator.setValue(field, p0),
          suffixIcon: field.hasValue
              ? IconButton(
                  onPressed: () {
                    validator.setValue(field, null);
                  },
                  icon: const Icon(Icons.remove_circle))
              : null,
        );
      case "trust_set_flags":
        return AppDropDownBottom(
          items: <TrustSetFlag, Widget>{
            for (var i in TrustSetFlag.values) i: Text(i.name)
          },
          label: "trust_set_flags".tr,
          value: field.value,
          key: ValueKey(field.value),
          onChanged: (v) {
            validator.setValue(field, v);
          },
          suffixIcon: field.hasValue
              ? IconButton(
                  onPressed: () {
                    validator.setValue(field, null);
                  },
                  icon: const Icon(Icons.remove_circle))
              : null,
        );
      case "cancel_nft_nft_token_offers":
        final TransactionFormField<List<String>> f =
            field as TransactionFormField<List<String>>;

        return AnimatedSize(
          duration: APPConst.animationDuraion,
          child: Column(
            key: ValueKey<int?>(f.value?.length),
            children: [
              ...List.generate(f.value?.length ?? 0, (index) {
                final v = f.value![index];
                return ContainerWithBorder(
                  validate: field.isCompleted,
                  onRemove: () {
                    validator.removeIndex(
                        field as TransactionFormField<List<String>>, index);
                  },
                  onRemoveIcon: const Icon(Icons.remove_circle),
                  child: OneLineTextWidget(v),
                );
              }),
              ContainerWithBorder(
                validate: field.isCompleted,
                onRemove: () {
                  context
                      .openSliverBottomSheet<String>(
                        validator.validatorName.tr,
                        child: StringWriterView(
                          defaultValue: null,
                          maxLength: RippleConst.rippleTranactionHashLength,
                          minLength: RippleConst.rippleTranactionHashLength,
                          title: PageTitleSubtitle(
                              title: field.name.tr,
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(field.subject!.tr),
                                ],
                              )),
                          buttonText: "setup_input".tr,
                          label: field.name.tr,
                        ),
                      )
                      .then((value) => validator.setListValue(
                          field as TransactionFormField<List<String>>, value));
                },
                onRemoveIcon: const Icon(Icons.add),
                child: Text("tap_to_input_value".tr, maxLines: 3),
              )
            ],
          ),
        );
      case "escrow_create_amount":
        return ContainerWithBorder(
            validate: field.isCompleted,
            onRemove: () {
              context
                  .openSliverBottomSheet<BigInt>(
                validator.validatorName.tr,
                child: SetupNetworkAmount(
                  token: account.network.coinParam.token,
                  max: account.address.address.currencyBalance,
                  min: BigInt.zero,
                  subtitle: PageTitleSubtitle(
                      title: field.name.tr, body: Text(field.subject!.tr)),
                ),
              )
                  .then(
                (value) {
                  if (value == null) {
                    validator.setValue(field, null);
                  } else {
                    validator.setValue(
                        field,
                        IntegerBalance(
                            value, account.network.coinParam.decimal));
                  }
                },
              );
            },
            onRemoveIcon:
                field.hasValue ? const Icon(Icons.edit) : const Icon(Icons.add),
            child: !field.hasValue
                ? Text("tap_to_enter_amount".tr)
                : CoinPriceView(
                    token: account.network.coinParam.token,
                    balance: field.value,
                    style: context.textTheme.titleLarge));

      default:
        return const Text(
          "unsuported field",
          style: TextStyle(fontSize: 25, color: Colors.red),
        );
    }
  }
}

class _GenerateFulFillmentView extends StatefulWidget {
  const _GenerateFulFillmentView();

  @override
  State<_GenerateFulFillmentView> createState() =>
      _GenerateFulFillmentViewState();
}

class _GenerateFulFillmentViewState extends State<_GenerateFulFillmentView>
    with SafeState {
  final GlobalKey<StreamWidgetState> progressKey = GlobalKey();
  FulfillmentPreimageSha256? fulFillment;
  void generateFulFillment() async {
    if (progressKey.inProgress) return;
    if (fulFillment != null) {
      fulFillment = null;
      setState(() {});
      await MethodUtils.wait(milliseconds: 400);
    }
    progressKey.process();

    final result = await MethodUtils.call(() async {
      final rand = QuickCrypto.generateRandom();
      final fullFillment = FulfillmentPreimageSha256.generate(rand);
      return fullFillment;
    }, delay: APPConst.oneSecoundDuration);
    if (result.hasError) {
      progressKey.error();
    } else {
      fulFillment = result.result;
      progressKey.success();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "create_random_fulfillment".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("fulfillment_desc".tr),
                WidgetConstant.height8,
                Text("fulfillment_desc2".tr)
              ],
            )),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: fulFillment == null
              ? WidgetConstant.sizedBox
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("fulfillment".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: CopyTextIcon(
                      dataToCopy: fulFillment!.fulfillment,
                      isSensitive: true,
                      widget: Text(fulFillment!.fulfillment),
                    )),
                    WidgetConstant.height20,
                    Text("condition".tr, style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: CopyTextIcon(
                      dataToCopy: fulFillment!.condition,
                      isSensitive: true,
                      widget: Text(fulFillment!.condition),
                    ))
                  ],
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: APPConst.animationDuraion,
              child: Padding(
                padding: WidgetConstant.paddingVertical20,
                child: fulFillment == null
                    ? StreamWidget(
                        key: progressKey,
                        buttonWidget: FilledButton(
                            onPressed: generateFulFillment,
                            child: Text("generate".tr)))
                    : Row(children: [
                        FilledButton(
                            onPressed: () {
                              context
                                  .openSliverDialog<bool>(
                                      (p0) => DialogTextView(
                                            text: "saved_fulfillment_desc".tr,
                                            buttonWidget:
                                                const DialogDoubleButtonView(),
                                          ),
                                      "fulfillment".tr)
                                  .then((value) {
                                if (value == true && context.mounted) {
                                  context.pop(fulFillment?.condition);
                                }
                              });
                            },
                            child: Text("apply_for_condition".tr)),
                        WidgetConstant.width8,
                        IconButton(
                            onPressed: generateFulFillment,
                            icon: const Icon(Icons.refresh))
                      ]),
              ),
            )
          ],
        )
      ],
    );
  }
}
