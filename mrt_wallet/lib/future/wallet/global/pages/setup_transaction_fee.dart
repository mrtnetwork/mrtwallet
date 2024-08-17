import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/setup_amount.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SetupTransactionFee extends StatefulWidget {
  const SetupTransactionFee(
      {super.key,
      required this.type,
      required this.network,
      required this.fees,
      this.customFee,
      this.max});
  final WalletNetwork network;
  final String? type;
  final BigInt? max;
  final BigInt? customFee;
  final Map<String, IntegerBalance> fees;
  @override
  State<SetupTransactionFee> createState() => _SetupTransactionFeeState();
}

class _SetupTransactionFeeState extends State<SetupTransactionFee>
    with SafeState {
  late String? type = widget.type;
  late final IntegerBalance feeRate = IntegerBalance(
      type != null ? BigInt.zero : widget.customFee ?? BigInt.zero,
      widget.network.coinParam.decimal);

  void onChange(String? newType, {BigInt? customPrice}) {
    if (newType == null && customPrice == null) return;
    if (newType != null && customPrice != null) return;
    type = newType;
    feeRate.updateBalance(customPrice ?? BigInt.zero);
    setState(() {});
    onSetup();
  }

  void onSetup() async {
    await MethodUtils.wait(milliseconds: 200);
    if (mounted) {
      // ignore: use_build_context_synchronously
      context.pop((type, feeRate.balance));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "setup_transaction_fee".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("transacation_fee_desc".tr),
                WidgetConstant.height8,
                Text("transaction_fee_desc2".tr),
                WidgetConstant.height8,
                Text("transaction_fee_desc3".tr)
              ],
            )),
        ...List.generate(
          widget.fees.length,
          (index) {
            final keys = widget.fees.keys.toList();
            return AppRadioListTile<String>(
              value: keys[index],
              title: Text(keys[index].camelCase),
              subtitle: CoinPriceView(
                balance: widget.fees[keys[index]],
                token: widget.network.coinParam.token,
                disableTooltip: true,
                style: context.textTheme.titleLarge,
              ),
              groupValue: type,
              onChanged: (value) {
                onChange(value);
              },
            );
          },
        ),
        Column(children: [
          AppRadioListTile(
            value: null,
            groupValue: type,
            title: Text("custom_fee".tr),
            subtitle: type == null
                ? CoinPriceView(
                    disableTooltip: true,
                    balance: feeRate,
                    token: widget.network.coinParam.token,
                    style: context.textTheme.titleLarge,
                  )
                : null,
            onChanged: (value) {
              context
                  .openSliverBottomSheet<BigInt>("setup_custom_fee".tr,
                      child: SetupNetworkAmount(
                        token: widget.network.coinParam.token,
                        max: widget.max,
                        min: BigInt.zero,
                        buttonText: "setup_transaction_fee".tr,
                        subtitle: PageTitleSubtitle(
                            title: "transaction_fee".tr,
                            body: Text("transaction_fee_desc4".tr)),
                      ))
                  .then((value) {
                onChange(null, customPrice: value);
              });
            },
          ),
        ]),
      ],
    );
  }
}
