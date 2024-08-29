import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/on_chain.dart';
import 'create_witness.dart';
import 'delegated_resource.dart';
import 'frozen_balance_v2.dart';
import 'tron_fee_details_view.dart';
import 'undelegated_resource.dart';
import 'unfreez_balance_v2.dart';
import 'update_account.dart';
import 'update_account_permission_feilds.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class TronTransactionFieldsView extends StatelessWidget {
  const TronTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<TronTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<TronTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<TronChain>(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, switchAccount) => MrtViewBuilder<
              TronTransactionStateController>(
          repositoryId: StateConst.tron,
          controller: () => TronTransactionStateController(
              walletProvider: wallet, account: chain, validator: validator),
          builder: (controller) {
            return PageProgress(
              key: controller.progressKey,
              initialStatus: PageProgressStatus.progress,
              initialWidget:
                  ProgressWithTextView(text: "retrieving_network_condition".tr),
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
                                key: ValueKey<ITronAddress?>(
                                    controller.address)),
                            onRemove: () {
                              context
                                  .openSliverBottomSheet<ITronAddress>(
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
                          _TronTransactionFields(
                              account: chain,
                              validator: controller.validator,
                              address: controller.address),
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
                          TronFeeDetailsView(transaction: controller),
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

class _TronTransactionFields extends StatelessWidget {
  const _TronTransactionFields(
      {required this.validator, required this.account, required this.address});
  final LiveTransactionForm<TronTransactionForm> validator;
  final TronChain account;
  final ITronAddress address;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value;
      switch (field.type) {
        case TransactionContractType.accountPermissionUpdateContract:
          return TronAccountUpdatePermissionFieldsView(
              account: account, address: address, validator: field);
        case TransactionContractType.transferContract:
        case TransactionContractType.transferAssetContract:
        case TransactionContractType.triggerSmartContract:
          return _TronTransactionTransferFields(field: field, account: account);
        case TransactionContractType.freezeBalanceV2Contract:
          return TronFreezBalanceV2FieldsView(
              account: account, address: address, validator: field);
        case TransactionContractType.unfreezeBalanceV2Contract:
          return TronUnFreezBalanceV2FieldsView(
              account: account, address: address, validator: field);
        case TransactionContractType.delegateResourceContract:
          return TronDelegatedResourceFieldsView(
              account: account, address: address, validator: field);
        case TransactionContractType.unDelegateResourceContract:
          return TronUnDelegatedResourceFieldsView(
              account: account, address: address, validator: field);
        case TransactionContractType.witnessCreateContract:
        case TransactionContractType.witnessUpdateContract:
          return TronCreateWitnessFieldsView(
              account: account, address: address, validator: field);
        case TransactionContractType.accountUpdateContract:
          return TronUpdateAccountFieldsView(
              account: account, address: address, validator: field);
        default:
          return WidgetConstant.sizedBox;

        /// TronUpdateAccountFieldsView
      }
    });
  }
}

class _TronTransactionTransferFields extends StatelessWidget {
  const _TronTransactionTransferFields(
      {required this.field, required this.account});
  final TronTransferForm field;
  final TronChain account;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.transferToken != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleLarge),
              WidgetConstant.height8,
              TokenDetailsView(
                token: field.transferToken!,
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
                .openSliverBottomSheet<ReceiptAddress<TronAddress>>(
                    "recipient".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (c) => SelectRecipientAccountView<TronAddress>(
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
                max: field.transferToken?.balance.value.balance ??
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
