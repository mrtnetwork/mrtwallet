import 'package:blockchain_utils/numbers/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/receipt_address_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/token_details_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/transaction_amount.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RipplePaymentFieldsView extends StatelessWidget {
  const RipplePaymentFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final CryptoAccountAddress address;
  final NetworkAccountCore account;
  final RipplePaymentValidator validator;

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
                .openSliverBottomSheet<ReceiptAddress>("recipient".tr,
                    maxExtend: 0.8,
                    minExtent: 0.7,
                    initialExtend: 0.7,
                    child: SelectNetworkAddressView(account: account))
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
                  network: account.network,
                  max: address.address.balance.value.balance,
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
                  validator.setValue(
                      validator.amount,
                      NoneDecimalBalance(
                          value, account.network.coinParam.decimal));
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
                  validator.fieldsName.tr,
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
                    buttomText: "setup_input".tr,
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
