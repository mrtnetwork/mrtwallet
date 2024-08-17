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

class CosmosTransactionFieldsView extends StatelessWidget {
  const CosmosTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<CosmosTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<CosmosTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<CosmosChain>(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, switchAccount) => MrtViewBuilder<
              CosomosTransactionStateController>(
          repositoryId: StateConst.cosmos,
          controller: () => CosomosTransactionStateController(
              walletProvider: wallet,
              account: chain,
              network: chain.network,
              apiProvider: chain.provider()!,
              address: chain.address,
              validator: validator),
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
                            onRemoveIcon: const Icon(Icons.edit),
                            child: AddressDetailsView(
                                address: controller.address,
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
                                    centerContent: false,
                                  )
                                  .then(switchAccount);
                            },
                          ),
                          WidgetConstant.height20,
                          _CosmosTransactionsFields(
                            controller: controller,
                            validator: controller.validator,
                          ),
                          WidgetConstant.height20,
                          Text("transaction_fee".tr,
                              style: context.textTheme.titleMedium),
                          Text("cost_for_transaction".tr),
                          WidgetConstant.height8,
                          ContainerWithBorder(
                            validateText: controller.feeError?.tr,
                            validate: controller.feeError == null &&
                                controller.hasFee,
                            onTapError: () {
                              controller.simulateTr();
                            },
                            onRemove: () {
                              if (controller.isThorChain) {
                                return;
                              }
                              context
                                  .openSliverBottomSheet<BigInt>(
                                    "setup_custom_fee".tr,
                                    child: SetupNetworkAmount(
                                      token: controller.network.coinParam.token,
                                      max: controller.address.address.balance
                                          .value.balance,
                                      min: BigInt.zero,
                                      subtitle: PageTitleSubtitle(
                                          title: "transaction_fee".tr,
                                          body: Column(
                                            children: [
                                              Text("transaction_fee_desc3".tr),
                                              WidgetConstant.height8,
                                              ContainerWithBorder(
                                                  child: CoinPriceView(
                                                balance: controller.feeAmount,
                                                token: controller
                                                    .network.coinParam.token,
                                                style: context
                                                    .textTheme.titleLarge,
                                              )),
                                            ],
                                          )),
                                    ),
                                  )
                                  .then(controller.setupFee);
                            },
                            onRemoveIcon: StreamWidget(
                              buttonWidget: controller.isThorChain
                                  ? Icon(Icons.circle,
                                      color: context.colors.transparent)
                                  : const Icon(Icons.edit),
                              key: controller.feeProgressKey,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(controller.feeType.name.tr,
                                    style: context.textTheme.labelLarge),
                                CoinPriceView(
                                  balance: controller.feeAmount,
                                  token: controller.network.coinParam.token,
                                  style: context.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          WidgetConstant.height20,
                          Text("setup_memo".tr,
                              style: context.textTheme.titleMedium),
                          WidgetConstant.height8,
                          ContainerWithBorder(
                              onRemoveIcon: controller.hasMemo
                                  ? const Icon(Icons.remove_circle)
                                  : const Icon(Icons.add_box),
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
                                        ? Text(controller.memo ?? "")
                                        : Text("tap_to_add_memo".tr,
                                            style:
                                                context.textTheme.labelLarge),
                                  ),
                                ],
                              )),
                          InsufficientBalanceErrorView(
                            verticalMargin: WidgetConstant.paddingVertical10,
                            balance: controller.remindAmount,
                            token: controller.network.coinParam.token,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FixedElevatedButton(
                                padding: WidgetConstant.paddingVertical20,
                                onPressed: controller.trIsReady
                                    ? controller.sendTransaction
                                    : null,
                                child: Text("send_transaction".tr),
                              )
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
        controller: controller,
        field: field,
      );
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
          children:
              List.generate(field.destination.value?.length ?? 0, (index) {
            final CosmosOutputWithBalance receiver =
                field.destination.value![index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              onRemoveIcon: const Icon(Icons.remove_circle),
              validate: receiver.hasAmount,
              onRemove: () {
                field.onRemoveReceiver(receiver.address.networkAddress.address);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.colors.secondary,
                      child: ReceiptAddressDetailsView(
                        address: receiver.address,
                        color: context.colors.onSecondary,
                      )),
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<BigInt>(
                        "setup_output_amount".tr,
                        child: SetupNetworkAmount(
                          token: field.network.coinParam.token,
                          max: controller.remindAmount.balance +
                              receiver.balance.balance,
                          min: BigInt.zero,
                          subtitle: PageTitleSubtitle(
                              title: "receiver".tr,
                              body: ContainerWithBorder(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OneLineTextWidget(receiver.address.view)
                                ],
                              ))),
                        ),
                      )
                          .then((amount) {
                        field.setBalance(
                            receiver.address.networkAddress.address, amount);
                      });
                    },
                    validate: receiver.hasAmount,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.colors.onSecondary),
                    backgroundColor: context.colors.secondary,
                    child: CoinPriceView(
                      balance: receiver.balance,
                      token: field.network.coinParam.token,
                      style: context.textTheme.titleLarge
                          ?.copyWith(color: context.colors.onSecondary),
                      symbolColor: context.colors.onSecondary,
                      showTokenImage: true,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        ContainerWithBorder(
          validate: field.destination.hasValue,
          onRemove: () {
            context
                .openSliverBottomSheet<ReceiptAddress<CosmosBaseAddress>>(
                    "receiver_address".tr,
                    bodyBuilder: (c) =>
                        SelectRecipientAccountView<CosmosBaseAddress>(
                            account: controller.account, scrollController: c),
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9)
                .then(
              (value) {
                field.setReceiver(
                    address: value,
                    onExists: () {
                      context.showAlert("address_already_exist".tr);
                    },
                    network: controller.network);
              },
            );
          },
          onRemoveIcon: const Icon(Icons.add_box),
          child: Text("tap_to_add_new_receipment".tr),
        ),
      ],
    );
  }
}
