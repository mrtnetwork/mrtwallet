import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';

class RipplePaymentFieldsView extends StatelessWidget {
  const RipplePaymentFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final RippleChain account;
  final RipplePaymentForm validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (validator.issueToken != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleLarge),
              WidgetConstant.height8,
              TokenDetailsView(
                token: validator.issueToken!,
                onSelectWidget: WidgetConstant.sizedBox,
              ),
              WidgetConstant.height20,
            ],
          ),
        ReceiptAddressView(
          address: validator.destination.value,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<XRPAddress>>(
                    "recipient".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (c) => SelectRecipientAccountView<XRPAddress>(
                        account: account, scrollController: c))
                .then(
              (value) {
                validator.setValue(validator.destination, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: validator.amount.value,
          validate: validator.amount.isCompleted,
          onTap: () {
            if (validator.issueToken == null) {
              context
                  .openSliverBottomSheet<BigInt>(
                "setup_output_amount".tr,
                child: SetupNetworkAmount(
                  token: account.network.coinParam.token,
                  max: address.address.currencyBalance,
                  min: BigInt.zero,
                  subtitle: validator.destination.hasValue
                      ? ReceiptAddressView(
                          address: validator.destination.value,
                          onTap: null,
                        )
                      : const SizedBox(),
                ),
              )
                  .then((value) {
                if (value == null) {
                  validator.setValue(validator.amount, null);
                } else {
                  validator.setValue(validator.amount,
                      IntegerBalance(value, account.network.coinParam.decimal));
                }
              });
            } else {
              context
                  .openSliverBottomSheet<BigRational>(
                "setup_output_amount".tr,
                child: SetupDecimalTokenAmountView(
                  token: validator.token,
                  max: validator.issueToken!.balance.value.balance,
                  min: BigRational.zero,
                  subtitle: validator.destination.hasValue
                      ? ReceiptAddressView(
                          address: validator.destination.value,
                          onTap: null,
                        )
                      : const SizedBox(),
                ),
              )
                  .then((value) {
                validator.setValue(validator.amount,
                    value == null ? null : DecimalBalance.fromRational(value));
              });
            }
          },
          token: validator.token,
        ),
        WidgetConstant.height20,
        Text("invoiceid".tr, style: context.textTheme.titleMedium),
        Text("ripple_payment_invoiceid".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  validator.validatorName.tr,
                  child: StringWriterView(
                    defaultValue: validator.invoiceId.value,
                    maxLength: RippleConst.rippleTranactionHashLength,
                    minLength: RippleConst.rippleTranactionHashLength,
                    title: PageTitleSubtitle(
                        title: "invoiceid".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ripple_payment_invoiceid".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "invoiceid".tr,
                  ),
                )
                .then(
                  (value) => validator.setValue(validator.invoiceId, value),
                );
          },
          onRemoveIcon: validator.invoiceId.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(validator.invoiceId.value ?? "tap_to_input_value".tr,
              maxLines: 3),
        ),
        WidgetConstant.height20,
        Text("payment_flags".tr, style: context.textTheme.titleMedium),
        Text("ripple_payment_flags".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: <PaymentFlag, Widget>{
            for (var i in PaymentFlag.values) i: Text(i.name)
          },
          label: "payment_flags".tr,
          value: validator.flag.value,
          key: ValueKey(validator.flag.value),
          onChanged: (v) {
            validator.setValue(validator.flag, v);
          },
          suffixIcon: validator.flag.hasValue
              ? IconButton(
                  onPressed: () {
                    validator.setValue(validator.flag, null);
                  },
                  icon: const Icon(Icons.remove_circle))
              : null,
        )
      ],
    );
  }
}
