import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/pages/gas_fee.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class EthereumTransactionFieldsView extends StatelessWidget {
  const EthereumTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<EthereumTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<EthereumTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<EthereumChain>(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, switchAccount) => MrtViewBuilder<
              EthereumTransactionStateController>(
          controller: () => EthereumTransactionStateController(
              walletProvider: wallet, account: chain, validator: validator),
          repositoryId: StateConst.ethereum,
          builder: (controller) {
            return PageProgress(
              key: controller.progressKey,
              backToIdle: APPConst.oneSecoundDuration,
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
                                key:
                                    ValueKey<IEthAddress?>(controller.address)),
                            onRemove: () {
                              context
                                  .openSliverBottomSheet<IEthAddress>(
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
                          _ETHTransactionFileds(
                              account: chain, validator: controller.validator),
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
                          WidgetConstant.height20,
                          EthereumGasFeeView(transaction: controller),
                          WidgetConstant.height20,
                          InsufficientBalanceErrorView(
                            verticalMargin: WidgetConstant.paddingVertical10,
                            balance: controller.remindAmount.$1,
                            token: controller.remindAmount.$2,
                          ),
                          ErrorTextContainer(
                              error: controller.error,
                              verticalMargin: WidgetConstant.paddingVertical10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FixedElevatedButton(
                                padding: WidgetConstant.paddingVertical20,
                                onPressed: controller.trIsReady
                                    ? controller.sedTransaction
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

class _ETHTransactionFileds extends StatelessWidget {
  const _ETHTransactionFileds({required this.validator, required this.account});
  final LiveTransactionForm<EthereumTransactionForm> validator;
  final EthereumChain account;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value as EthereumTransferForm;
      switch (field.mode) {
        case ETHTransactionMode.transfer:
        case ETHTransactionMode.erc20Transfer:
          return _ETHTransactionTransferFields(field: field, account: account);
        default:
          return WidgetConstant.sizedBox;
      }
    });
  }
}

class _ETHTransactionTransferFields extends StatelessWidget {
  const _ETHTransactionTransferFields(
      {required this.field, required this.account});
  final EthereumTransferForm field;
  final EthereumChain account;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.erc20Token != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleLarge),
              WidgetConstant.height8,
              TokenDetailsView(
                token: field.erc20Token!,
                onSelectWidget: WidgetConstant.sizedBox,
              ),
              WidgetConstant.height20,
            ],
          ),
        ReceiptAddressView(
          address: field.destination.value,
          subtitle: "receiver_address_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<ETHAddress>>(
                    "recipient".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (c) => SelectRecipientAccountView<ETHAddress>(
                        account: account, scrollController: c))
                .then(
              (value) {
                field.setValue(field.destination, value);
              },
            );
          },
        ),
        WidgetConstant.height8,
        TransactionAmountView(
          amount: field.amount.value,
          subtitle: "input_the_amout".tr,
          validate: field.amount.isCompleted,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
              "setup_output_amount".tr,
              child: SetupNetworkAmount(
                token: field.token,
                max: field.erc20Token?.balance.value.balance ??
                    account.address.address.currencyBalance,
                min: BigInt.zero,
                subtitle: field.destination.hasValue
                    ? ReceiptAddressView(
                        address: field.destination.value,
                        onTap: null,
                      )
                    : const SizedBox(),
              ),
            )
                .then((value) {
              if (value == null) {
                field.setValue(field.amount, null);
              } else {
                field.setValue(
                    field.amount, IntegerBalance(value, field.token.decimal!));
              }
            });
          },
          token: field.token,
        ),
      ],
    );
  }
}
