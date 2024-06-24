import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';

import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/transaction/controller/controller.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/transaction/fields/global/gas_fee_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/transaction/global/controller_ethereum_transaction_account.dart';
import 'package:mrt_wallet/future/widgets/button.dart';
import 'package:mrt_wallet/future/widgets/constraints_box_view.dart';
import 'package:mrt_wallet/future/widgets/container_with_border.dart';
import 'package:mrt_wallet/future/widgets/error_text_container.dart';
import 'package:mrt_wallet/future/widgets/page_title_subtitle.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/page_progress.dart';
import 'package:mrt_wallet/future/widgets/string_writer.dart';
import 'package:mrt_wallet/future/widgets/widget_constant.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class EthereumTransactionFieldsView extends StatelessWidget {
  const EthereumTransactionFieldsView({super.key, this.field});
  final LiveTransactionValidator<EthereumTransactionValidator>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionValidator<EthereumTransactionValidator> validator =
        field ?? context.getArgruments();
    return ControllerEthereumTransactionAccountView(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, address, switchAccount) => MrtViewBuilder<
              EthereumTransactionStateController>(
          controller: () => EthereumTransactionStateController(
              walletProvider: wallet,
              account: chain.account,
              network: chain.network as APPEVMNetwork,
              apiProvider: chain.provider()!,
              address: address,
              validator: validator),
          builder: (controller) {
            return PageProgress(
              key: controller.progressKey,
              backToIdle: AppGlobalConst.oneSecoundDuration,
              child: () => CustomScrollView(
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
                                address: controller.owner,
                                key: ValueKey<IEthAddress?>(controller.owner)),
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
                              account: chain.account,
                              validator: controller.validator),
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
                                      buttomText: "setup_memo".tr,
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
  final LiveTransactionValidator<EthereumTransactionValidator> validator;
  final NetworkAccountCore account;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value as EthereumTransferValidator;
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
  final EthereumTransferValidator field;
  final NetworkAccountCore account;
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
                    account.address.address.balance.value.balance,
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
                field.setValue(field.amount,
                    NoneDecimalBalance(value, field.token.decimal!));
              }
            });
          },
          token: field.token,
        ),
      ],
    );
  }
}
