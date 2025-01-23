import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'fee.dart';
import 'pick_token.dart';

class CosmosTransactionFieldsView extends StatelessWidget {
  const CosmosTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<CosmosTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<CosmosTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<CosmosChain>(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, switchAccount) =>
          MrtViewBuilder<CosomosTransactionStateController>(
              repositoryId: StateConst.cosmos,
              controller: () => CosomosTransactionStateController(
                  walletProvider: wallet, account: chain, validator: validator),
              builder: (controller) {
                return PageProgress(
                  key: controller.progressKey,
                  backToIdle: APPConst.oneSecoundDuration,
                  initialStatus: StreamWidgetStatus.progress,
                  child: (c) => CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ConstraintsBoxView(
                          padding: WidgetConstant.padding20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("account".tr,
                                  style: context.textTheme.titleLarge),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                onRemoveIcon: Icon(Icons.edit,
                                    color: context.onPrimaryContainer),
                                child: AddressDetailsView(
                                    address: controller.address,
                                    color: context.onPrimaryContainer,
                                    key: ValueKey<ICosmosAddress?>(
                                        controller.address)),
                                onRemove: () {
                                  context
                                      .openSliverBottomSheet<ICosmosAddress>(
                                          "switch_account".tr,
                                          child: SwitchOrSelectAccountView(
                                            account: controller.account,
                                            showMultiSig: true,
                                          ),
                                          minExtent: 0.5,
                                          maxExtend: 0.9,
                                          initialExtend: 0.7,
                                          centerContent: false)
                                      .then(switchAccount);
                                },
                              ),
                              WidgetConstant.height20,
                              _CosmosTransactionsFields(
                                  controller: controller,
                                  validator: controller.validator),
                              WidgetConstant.height20,
                              Text("transaction_fee".tr,
                                  style: context.textTheme.titleMedium),
                              Text("cost_for_transaction".tr),
                              WidgetConstant.height8,
                              _CosmosFeeView(controller: controller),
                              WidgetConstant.height20,
                              Text("setup_memo".tr,
                                  style: context.textTheme.titleMedium),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                  onRemoveIcon:
                                      AddOrEditIconWidget(controller.hasMemo),
                                  onRemove: () {
                                    controller.onTapMemo((s) async {
                                      final result = await context
                                          .openSliverBottomSheet<String>(
                                        "transaction_memo".tr,
                                        child: StringWriterView(
                                          defaultValue: controller.memo,
                                          title: PageTitleSubtitle(
                                              title: "setup_memo".tr,
                                              body: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: controller.hasMemo
                                            ? Text(controller.memo ?? "",
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .bodyMedium)
                                            : Text("tap_to_add_memo".tr,
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .bodyMedium),
                                      ),
                                    ],
                                  )),
                              InsufficientBalanceErrorView(
                                verticalMargin:
                                    WidgetConstant.paddingVertical10,
                                balance: controller.remindAmount,
                                token: controller.network.coinParam.token,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FixedElevatedButton(
                                      padding: WidgetConstant.paddingVertical40,
                                      onPressed: controller.trIsReady
                                          ? controller.sendTransaction
                                          : null,
                                      child: Text("send_transaction".tr))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
    );
  }
}

class _CosmosTransactionsFields extends StatelessWidget {
  const _CosmosTransactionsFields(
      {required this.validator, required this.controller});
  final LiveTransactionForm<CosmosTransactionForm> validator;
  final CosomosTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value as CosmosTransferForm;
      return _CosmosTransactionTransferFields(
          controller: controller, field: field);
    });
  }
}

class _CosmosTransactionTransferFields extends StatelessWidget {
  const _CosmosTransactionTransferFields(
      {required this.controller, required this.field});
  final CosomosTransactionStateController controller;
  final CosmosTransferForm field;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
        Text("amount_for_each_output".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(field.destinations.value.length, (index) {
            final CosmosOutputWithBalance receiver =
                field.destinations.value[index];
            final Token transferToken =
                receiver.token?.token ?? controller.network.token;
            final hasTokenBalance =
                !(field.remindTokenAmounts[receiver.token]?.isNegative ??
                    false);
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              enableTap: false,
              onRemoveIcon:
                  Icon(Icons.remove_circle, color: context.onPrimaryContainer),
              validate: receiver.hasAmount && hasTokenBalance,
              onRemove: () {
                field.onRemoveReceiver(receiver);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<CW20Token>(
                            "transfer".tr,
                            centerContent: false,
                            initialExtend: 1,
                            child: CosmosTransactionPickTokenView(
                                address: controller.address),
                          )
                          .then((e) => field.setToken(receiver, e));
                    },
                    backgroundColor: context.onPrimaryContainer,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    child: TokenDetailsWidget(
                      token: transferToken,
                      color: context.primaryContainer,
                      radius: APPConst.circleRadius25,
                    ),
                  ),
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                          address: receiver.address,
                          color: context.primaryContainer)),
                  ContainerWithBorder(
                    onRemove: () {
                      final max = field.max(
                          address: controller.address,
                          fee: controller.fee.feeAmount.balance,
                          destination: receiver);
                      context
                          .openSliverBottomSheet<BigInt>(
                        "setup_output_amount".tr,
                        initialExtend: 1,
                        child: SetupNetworkAmount(
                          token: transferToken,
                          max: max,
                          min: BigInt.zero,
                          subtitle: PageTitleSubtitle(
                              title: "receiver".tr,
                              body: ReceiptAddressView(
                                  address: receiver.address, title: null)),
                        ),
                      )
                          .then((amount) {
                        field.setBalance(receiver, amount);
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
                  if (!hasTokenBalance)
                    InsufficientBalanceErrorView(
                      balance: field.remindTokenAmounts[receiver.token]!,
                      token: transferToken,
                    )
                ],
              ),
            );
          }),
        ),
        ContainerWithBorder(
          validate: field.destinations.hasValue,
          onRemove: () {
            context
                .openSliverBottomSheet<List<ReceiptAddress<CosmosBaseAddress>>>(
              "receiver_address".tr,
              bodyBuilder: (scrollController) =>
                  SelectRecipientAccountView<CosmosBaseAddress>(
                      account: controller.account,
                      scrollController: scrollController,
                      multipleSelect: true),
              maxExtend: 1,
              minExtent: 0.8,
              initialExtend: 0.9,
            )
                .then(
              (value) {
                field.setReceiver(
                    addresses: value, network: controller.network);
              },
            );
          },
          onRemoveIcon: Icon(Icons.add_box, color: context.onPrimaryContainer),
          child: Text("tap_to_add_new_receipment".tr,
              style: context.onPrimaryTextTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _CosmosFeeView extends StatelessWidget {
  final CosomosTransactionStateController controller;
  const _CosmosFeeView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerWithBorder(
            onRemove: controller.hasMultipleFeeToken
                ? () {
                    context
                        .openSliverBottomSheet<CW20Token>(
                          "transfer".tr,
                          centerContent: false,
                          initialExtend: 1,
                          child: CosmosTransactionPickTokenView(
                            tokens: controller.feeTokens,
                          ),
                        )
                        .then(controller.setFeeToken);
                  }
                : null,
            onRemoveIcon: EditOrRemoveIconWidget(
              controller.isNativeTokenAsFee,
              color: context.primaryContainer,
            ),
            backgroundColor: context.onPrimaryContainer,
            child: TokenDetailsWidget(
              token: controller.fee.token,
              color: context.primaryContainer,
              radius: APPConst.circleRadius25,
            ),
          ),
          ContainerWithBorder(
            onRemoveIcon: ButtonProgress(
              color: context.primaryContainer,
              child: (context) => EditOrRemoveIconWidget(
                  controller.fee.feeType.isManually,
                  color: context.primaryContainer),
              key: controller.feeProgressKey,
            ),
            backgroundColor: context.onPrimaryContainer,
            validateText: controller.feeError?.tr,
            validate: controller.feeError == null && controller.hasFee,
            onTapError: () {
              controller.simulateTr();
            },
            onRemove: () {
              controller.setupFee(
                onSetupFee: (fee) => context
                    .openSliverBottomSheet<CosmosFeeInfo>("setup_custom_fee".tr,
                        child: CosmosSetTransferFeeView(fee: fee)),
                onRemoveFee: () => context.openSliverDialog(
                    (context) => DialogTextView(
                        text: "switch_to_automatic_fee_desc".tr,
                        buttonWidget: const DialogDoubleButtonView()),
                    "automatically_setup_fee".tr),
              );

              // ;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.fee.feeType.name.tr,
                    style: context.primaryTextTheme.labelLarge),
                CoinPriceView(
                    balance: controller.fee.feeAmount,
                    token: controller.feeToken,
                    style: context.primaryTextTheme.titleMedium,
                    symbolColor: context.primaryContainer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
