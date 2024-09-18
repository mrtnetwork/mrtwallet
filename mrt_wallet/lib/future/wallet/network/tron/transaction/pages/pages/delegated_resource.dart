import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/resource_v2/forms/delegated_resource.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/tron/src/address/tron_address.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronDelegatedResourceFieldsView extends StatelessWidget {
  const TronDelegatedResourceFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronDelegatedResourceV2Form validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("resource".tr, style: context.textTheme.titleMedium),
        Text("trx_stake_type".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: {
            for (final i in TronUtils.tronFrozenReosurce)
              i: Text(i.name.toLowerCase().camelCase)
          },
          label: "resource".tr,
          value: validator.resource.value,
          onChanged: (p0) {
            validator.setValue(validator.resource, p0);
          },
        ),
        AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: validator.resource.hasValue
              ? Column(
                  key: ValueKey(validator.resource.value),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("delegatable_amount".tr,
                        style: context.textTheme.titleMedium),
                    Text("delegatable_amount_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: CoinPriceView(
                            token: account.network.coinParam.token,
                            balance: validator.maxResourceBalance.amoumt)),
                    WidgetConstant.height20,
                    ReceiptAddressView(
                      address: validator.destination.value,
                      subtitle: "resource_receiver_address".tr,
                      title: "receiver_address".tr,
                      onTap: () {
                        context
                            .openSliverBottomSheet<ReceiptAddress<TronAddress>>(
                          "receiver_address".tr,
                          maxExtend: 1,
                          minExtent: 0.8,
                          initialExtend: 0.9,
                          bodyBuilder: (c) =>
                              SelectRecipientAccountView<TronAddress>(
                                  account: account,
                                  scrollController: c,
                                  subtitle:
                                      Text("resource_receiver_address".tr)),
                        )
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
                      subtitle: "resource_delegated_amount".tr,
                      title: "amount".tr,
                      validate: validator.amount.isCompleted,
                      onTap: () {
                        context
                            .openSliverBottomSheet<BigInt>(
                          "delegated_resource".tr,
                          child: SetupNetworkAmount(
                            token: account.network.coinParam.token,
                            max: validator.maxResourceBalance.amoumt.balance,
                            min: BigInt.zero,
                            subtitleText: "resource_delegated_amount".tr,
                          ),
                        )
                            .then((value) {
                          if (value == null) {
                            validator.setValue(validator.amount, null);
                          } else {
                            validator.setValue(
                                validator.amount,
                                IntegerBalance(value,
                                    account.network.coinParam.token.decimal!));
                          }
                        });
                      },
                      token: account.network.coinParam.token,
                    ),
                    WidgetConstant.height20,
                    Text("lock".tr, style: context.textTheme.titleMedium),
                    Text("tron_delegate_resource_lock_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: Switch(
                      value: validator.lock.value ?? false,
                      onChanged: (value) {
                        validator.setLockPerid(value);
                      },
                    )),
                    if (validator.lock.value ?? false)
                      AnimatedSize(
                        duration: APPConst.animationDuraion,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WidgetConstant.height20,
                            Text("lock_period".tr,
                                style: context.textTheme.titleMedium),
                            Text("tron_delegate_lock_time_desc".tr),
                            WidgetConstant.height8,
                            ContainerWithBorder(
                                onRemoveIcon: const Icon(Icons.edit),
                                onRemove: () {
                                  context
                                      .openSliverBottomSheet<BigRational>(
                                        "delegated_resource".tr,
                                        child: NumberWriteView(
                                          defaultValue:
                                              validator.lockPeriod.value,
                                          max: TronUtils.maxDelegatedLockPeriod,
                                          allowDecimal: false,
                                          allowSign: false,
                                          title: PageTitleSubtitle(
                                              title: "lock_period".tr,
                                              body: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "tron_delegate_lock_time_desc"
                                                          .tr),
                                                ],
                                              )),
                                          buttonText: "setup_input".tr,
                                          label: "lock_period".tr,
                                        ),
                                      )
                                      .then((value) => validator.setValue(
                                          validator.lockPeriod, value));
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: RichText(
                                            text: TextSpan(
                                                style: context
                                                    .textTheme.bodyMedium,
                                                children: [
                                          if (validator.lockPeriod.value ==
                                              null)
                                            TextSpan(
                                                text: "tap_to_input_value".tr)
                                          else ...[
                                            TextSpan(
                                                text: validator.lockPeriod.value
                                                    ?.toString()
                                                    .to3Digits),
                                            TextSpan(
                                                style:
                                                    context.textTheme.bodySmall,
                                                text:
                                                    " (${TronUtils.delegatedLockPeriodToDateTime(validator.lockPeriod.value!.toBigInt()).toDateAndTime()})")
                                          ],
                                        ]))),
                                    ToolTipView(
                                      message:
                                          "tron_delegate_lock_time_desc2".tr,
                                      waitDuration: null,
                                      child: const Icon(Icons.help),
                                    )
                                  ],
                                ))
                          ],
                        ),
                      )
                  ],
                )
              : WidgetConstant.sizedBox,
        )
      ],
    );
  }
}
