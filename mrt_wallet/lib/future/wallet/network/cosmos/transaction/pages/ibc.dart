import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/forms.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

import 'pick_channel_id.dart';
import 'pick_ibc_chain.dart';
import 'pick_token.dart';

class CosmosIbcTransferFields extends StatelessWidget {
  final CosmosIbcTransferForm form;
  final CosomosTransactionStateController controller;
  const CosmosIbcTransferFields(
      {required this.form, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("list_of_transfers".tr, style: context.textTheme.titleMedium),
        Text("fill_in_all_fields".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(form.destinations.value.length, (index) {
            final CosmosIbcOutputWithBalance receiver =
                form.destinations.value[index];
            final Token transferToken =
                receiver.token?.token ?? controller.network.token;
            final hasTokenBalance =
                !(form.remindTokenAmounts[receiver.token]?.isNegative ?? false);
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              enableTap: false,
              onRemoveIcon:
                  Icon(Icons.remove_circle, color: context.onPrimaryContainer),
              validate: receiver.hasAmount && hasTokenBalance,
              onRemove: () {
                form.onRemoveReceiver(receiver);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("destination_chain".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: TokenDetailsWidget(
                          token: receiver.chainData.token.token,
                          color: context.primaryContainer,
                          radius: APPConst.circleRadius25)),
                  WidgetConstant.height20,
                  Text("channel_id".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  Text("ibc_channel_desc".tr,
                      style: context.onPrimaryTextTheme.bodyMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    validate: receiver.hasChannelId,
                    onRemove: () {
                      context.openSliverBottomSheet("".tr,
                          bodyBuilder: (scrollController) =>
                              CosmosPickChannelIdView(
                                controller: scrollController,
                                sourceChain: controller.account,
                                destinationChain: receiver.chainData.chain,
                                onSelectChannelId: (p0, p1) {
                                  form.setChannelId(receiver, p1);
                                  context.pop();
                                },
                              ));
                    },
                    backgroundColor: context.onPrimaryContainer,
                    onRemoveIcon: AddOrEditIconWidget(receiver.hasChannelId,
                        color: context.primaryContainer),
                    child: Text(receiver.channelId ?? "tap_to_input_value".tr,
                        style: context.primaryTextTheme.bodyMedium),
                  ),
                  WidgetConstant.height20,
                  Text("transfer_token".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  Text(
                    "select_token_for_transfer".tr,
                    style: context.onPrimaryTextTheme.bodyMedium,
                  ),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<CW20Token>(
                            "transfer".tr,
                            centerContent: false,
                            child: CosmosTransactionPickTokenView(
                              address: controller.address,
                              network: controller.network,
                            ),
                          )
                          .then((e) => form.setToken(receiver, e));
                    },
                    backgroundColor: context.onPrimaryContainer,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    child: TokenDetailsWidget(
                        token: transferToken,
                        color: context.primaryContainer,
                        radius: APPConst.circleRadius25),
                  ),
                  WidgetConstant.height20,
                  Text("recipient".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      validate: receiver.hasAddress,
                      onRemoveIcon: AddOrEditIconWidget(
                        receiver.hasAddress,
                        color: context.primaryContainer,
                      ),
                      onRemove: () {
                        context
                            .openSliverBottomSheet<
                                ReceiptAddress<CosmosBaseAddress>>(
                          "receiver_address".tr,
                          bodyBuilder: (scrollController) =>
                              SelectRecipientAccountView<CosmosBaseAddress>(
                                  account: receiver.chainData.chain,
                                  scrollController: scrollController,
                                  multipleSelect: false),
                        )
                            .then(
                          (value) {
                            form.setReceiver(receiver, value);
                          },
                        );
                      },
                      child: ConditionalWidget(
                          enable: receiver.hasAddress,
                          onDeactive: (context) {
                            return Text("tap_to_choose_address".tr,
                                style: context.primaryTextTheme.bodyMedium);
                          },
                          onActive: (context) => ReceiptAddressDetailsView(
                              address: receiver.address!,
                              color: context.primaryContainer))),
                  WidgetConstant.height20,
                  Text("amount".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemove: () {
                      final max = form.max(
                          address: controller.address,
                          fee: controller.fee.feeAmount.balance,
                          destination: receiver);
                      context
                          .openSliverBottomSheet<BigInt>(
                        "setup_output_amount".tr,
                        child: SetupNetworkAmount(
                          token: transferToken,
                          max: max,
                          min: BigInt.zero,
                          subtitle: receiver.address == null
                              ? null
                              : PageTitleSubtitle(
                                  title: "receiver".tr,
                                  body: ReceiptAddressView(
                                      address: receiver.address, title: null)),
                        ),
                      )
                          .then((amount) {
                        form.setBalance(receiver, amount);
                      });
                    },
                    validate: receiver.hasAmount && hasTokenBalance,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinPriceView(
                      balance: receiver.balance,
                      token: transferToken,
                      style: context.primaryTextTheme.titleMedium,
                      symbolColor: context.primaryContainer,
                      showTokenImage: true,
                    ),
                  ),
                  WidgetConstant.height20,
                  Text("setup_memo".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemove: () {
                      form.onTapMemo(receiver, (s) async {
                        final result =
                            await context.openSliverBottomSheet<String>(
                          "transaction_memo".tr,
                          child: StringWriterView(
                            defaultValue: controller.memo,
                            title: PageTitleSubtitle(
                                title: "setup_memo".tr,
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("memo_desc1".tr),
                                    WidgetConstant.height8,
                                    Text("empty_desc".tr),
                                  ],
                                )),
                            buttonText: "setup_memo".tr,
                            label: "memo".tr,
                          ),
                        );
                        return result;
                      });
                    },
                    backgroundColor: context.onPrimaryContainer,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    child: Text(receiver.memo ?? "tap_to_add_memo".tr,
                        style: context.primaryTextTheme.bodyMedium),
                  ),
                  if (!hasTokenBalance)
                    InsufficientBalanceErrorView(
                      balance: form.remindTokenAmounts[receiver.token]!,
                      token: transferToken,
                    ),
                  WidgetConstant.height20,
                  Text("transaction_timeout".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    backgroundColor: context.onPrimaryContainer,
                    onRemove: () async {
                      final time = await showTimePicker(
                          context: context,
                          initialTime: receiver.timeout.timeOfDay());
                      form.setTimeout(receiver, time);
                    },
                    child: Text(receiver.timeout.toDateAndTimeWithSecound(),
                        style: context.primaryTextTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ),
        ContainerWithBorder(
          validate: form.destinations.hasValue,
          onRemove: () {
            context.openSliverBottomSheet("".tr,
                bodyBuilder: (scrollController) =>
                    CosmosIbcTransactionPickDestinationChainView(
                      scrollController: scrollController,
                      currentChain: controller.account,
                      onSelectChain: (context, chain) {
                        form.setDestinationChain(chain);
                        context.pop();
                      },
                    ));
          },
          onRemoveIcon: Icon(Icons.add_box, color: context.onPrimaryContainer),
          child: Text("tap_to_add_new_transfer".tr,
              style: context.onPrimaryTextTheme.bodyMedium),
        ),
        WidgetConstant.height20,
      ],
    );
  }
}
