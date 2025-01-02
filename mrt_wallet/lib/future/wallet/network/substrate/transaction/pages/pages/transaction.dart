import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'fee_info.dart';
import 'memo.dart';

class SubstrateTransactionFieldsView extends StatelessWidget {
  const SubstrateTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<SubstrateTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<SubstrateTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<SubstrateChain>(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, switchAccount) =>
          MrtViewBuilder<SubstrateTransactionStateController>(
              repositoryId: StateConst.substrate,
              controller: () => SubstrateTransactionStateController(
                  walletProvider: wallet,
                  account: chain,
                  network: chain.network,
                  apiProvider: chain.client,
                  address: chain.address,
                  validator: validator),
              builder: (controller) {
                return PageProgress(
                  key: controller.progressKey,
                  backToIdle: APPConst.oneSecoundDuration,
                  initialStatus: StreamWidgetStatus.idle,
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
                                onRemoveIcon: Icon(
                                  Icons.edit,
                                  color: context.onPrimaryContainer,
                                ),
                                child: AddressDetailsView(
                                    address: controller.address,
                                    color: context.onPrimaryContainer,
                                    key: ValueKey<ISubstrateAddress?>(
                                        controller.address)),
                                onRemove: () {
                                  context
                                      .openSliverBottomSheet<ISubstrateAddress>(
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
                              _SubstrateTransactionsFields(
                                  controller: controller,
                                  validator: controller.validator),
                              WidgetConstant.height20,
                              SubstrateTransactionMemoView(controller),
                              WidgetConstant.height20,
                              SubstrateTransactionFeeView(controller),
                              WidgetConstant.height20,
                              ErrorTextContainer(error: controller.error),
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

class _SubstrateTransactionsFields extends StatelessWidget {
  const _SubstrateTransactionsFields(
      {required this.validator, required this.controller});
  final LiveTransactionForm<SubstrateTransactionForm> validator;
  final SubstrateTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value as SubstrateTransferForm;
      return _SubstrateTransactionTransferFields(
          controller: controller, field: field);
    });
  }
}

class _SubstrateTransactionTransferFields extends StatelessWidget {
  const _SubstrateTransactionTransferFields(
      {required this.controller, required this.field});
  final SubstrateTransactionStateController controller;
  final SubstrateTransferForm field;
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
          children: List.generate(field.destination.value.length, (index) {
            final SubstrateOutputWithBalance receiver =
                field.destination.value[index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              enableTap: false,
              onRemoveIcon: Icon(
                Icons.remove_circle,
                color: context.onPrimaryContainer,
              ),
              validate: receiver.hasAmount,
              onRemove: () {
                field.onRemoveReceiver(receiver);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.colors.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                        address: receiver.address,
                        color: context.primaryContainer,
                      )),
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<BigInt>(
                        "setup_output_amount".tr,
                        initialExtend: 1,
                        child: SetupNetworkAmount(
                          token: field.network.coinParam.token,
                          max: field.maxTransfer(
                              account: controller.address, receiver: receiver),
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
                        field.setBalance(address: receiver, balance: amount);
                      });
                    },
                    validate: receiver.hasAmount,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinPriceView(
                      balance: receiver.balance,
                      token: field.network.coinParam.token,
                      style: context.primaryTextTheme.titleMedium,
                      symbolColor: context.colors.primaryContainer,
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
                .openSliverBottomSheet<List<ReceiptAddress<SubstrateAddress>>>(
                    "receiver_address".tr,
                    bodyBuilder: (scrollController) =>
                        SelectRecipientAccountView<SubstrateAddress>(
                          account: controller.account,
                          scrollController: scrollController,
                          multipleSelect: true,
                        ),
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9)
                .then(
              (value) {
                field.setReceiver(
                    addresses: value,
                    onExists: () {
                      context.showAlert("some_addresses_exist".tr);
                    });
              },
            );
          },
          onRemoveIcon: Icon(
            Icons.add_box,
            color: context.onPrimaryContainer,
          ),
          child: Text(
            "tap_to_add_new_receipment".tr,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
