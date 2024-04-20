import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/account_pages/account_controller.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/solana_pages/transaction/controller/solana_transaction_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/transfer/transfer.dart';

class SolanaTransactionFieldsView extends StatelessWidget {
  const SolanaTransactionFieldsView({super.key, required this.validator});
  final LiveTransactionValidator<SolanaTransactionValidator> validator;
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<APPSolanaNetwork, ISolanaAddress>(
        childBulder: (wallet, chain, address, network, switchAccount) {
          return MrtViewBuilder<SolanaTransactionStateController>(
            controller: () => SolanaTransactionStateController(
                walletProvider: wallet,
                account: chain.account,
                network: network,
                address: address,
                apiProvider: chain.provider()!,
                validator: validator),
            builder: (controller) {
              return PageProgress(
                backToIdle: AppGlobalConst.oneSecoundDuration,
                key: controller.progressKey,
                child: () {
                  return CustomScrollView(
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
                                      key: ValueKey<ISolanaAddress?>(
                                          controller.owner)),
                                  onRemove: () {
                                    context
                                        .openSliverBottomSheet<ISolanaAddress>(
                                          "switch_account".tr,
                                          child: SwitchOrSelectAccountView(
                                              account: controller.account,
                                              showMultiSig: true),
                                          minExtent: 0.5,
                                          maxExtend: 0.9,
                                          initialExtend: 0.7,
                                          centerContent: false,
                                        )
                                        .then(switchAccount);
                                  },
                                ),
                                WidgetConstant.height20,
                                _SolanaTransactionFileds(
                                  account: chain.account,
                                  validator: controller.validator,
                                  network: controller.network,
                                ),
                                AnimatedSize(
                                  duration: AppGlobalConst.animationDuraion,
                                  child: !controller.hasFee
                                      ? WidgetConstant.sizedBox
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            WidgetConstant.height20,
                                            Text("transaction_fee".tr,
                                                style: context
                                                    .textTheme.titleLarge),
                                            WidgetConstant.height8,
                                            ContainerWithBorder(
                                                child: CoinPriceView(
                                              token: controller
                                                  .network.coinParam.token,
                                              balance: controller.fee,
                                              style:
                                                  context.textTheme.titleLarge,
                                            )),
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
                                            defaultValue: s,
                                            maxLength:
                                                SolanaConstants.memoLength,
                                            title: PageTitleSubtitle(
                                                title: "setup_memo".tr,
                                                body: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
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
                                              ? Text(controller.memoStr ?? "")
                                              : Text("tap_to_add_memo".tr,
                                                  style: context
                                                      .textTheme.labelLarge),
                                        ),
                                      ],
                                    )),
                                WidgetConstant.height20,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FixedElevatedButton(
                                      onPressed: controller.transactionIsReady
                                          ? controller.sendTransaction
                                          : null,
                                      child: Text("send_transaction".tr),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        title: "build_transacation".tr);
  }
}

class _SolanaTransactionFileds extends StatelessWidget {
  const _SolanaTransactionFileds(
      {required this.validator, required this.account, required this.network});
  final LiveTransactionValidator<SolanaTransactionValidator> validator;
  final NetworkAccountCore account;
  final AppNetworkImpl network;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value as SolanaTransferValidator;
      return _SolanaTransferFields(
        field: field,
        account: account,
        network: network,
      );
    });
  }
}

class _SolanaTransferFields extends StatelessWidget {
  const _SolanaTransferFields(
      {required this.field, required this.account, required this.network});
  final SolanaTransferValidator field;
  final NetworkAccountCore account;
  final AppNetworkImpl network;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.isTokenTransfer)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleLarge),
              WidgetConstant.height8,
              TokenDetailsView(
                token: field.splToken!,
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
                .openSliverBottomSheet<ReceiptAddress>("recipient".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (controller) => SelectRecipientAccountView(
                        account: account, scrollController: controller))
                .then(
              (value) {
                field.setValue(field.destination, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("recipient_info".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemoveIcon: StreamWidget(
              buttomWidget: Icon(
                Icons.circle,
                color: context.colors.transparent,
              ),
              key: field.accountKey,
            ),
            onRemove: () {
              if (!field.hasErrpr) return;
              field.updateAccountInfo();
            },
            child: !field.destination.hasValue
                ? Text("no_account_chosen".tr)
                : field.hasErrpr
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetConstant.errorIcon,
                          WidgetConstant.width8,
                          Expanded(
                            child: Text(
                              "request_error".tr,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : field.accountInfo == null
                        ? Text("account_not_found".tr)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("owner".tr,
                                  style: context.textTheme.labelLarge),
                              Text(field.accountInfo!.owner.address),
                              Divider(color: context.colors.onPrimaryContainer),
                              Text("executable".tr,
                                  style: context.textTheme.labelLarge),
                              Text(field.accountInfo!.executable.tr),
                            ],
                          )),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: field.amount.value,
          subtitle: "input_the_amout".tr,
          validate:
              field.amount.isCompleted && !field.showRequirementAmountAlert,
          validateError: field.showRequirementAmountAlert
              ? "amount_must_exceed".tr.replaceOne(PriceUtils.priceWithCoinName(
                  SolanaConstants.systemProgramRent.price,
                  network.coinParam.token.symbol))
              : null,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
              "setup_output_amount".tr,
              child: SetupNetworkAmount(
                token: field.token,
                max: field.isTokenTransfer
                    ? field.splToken!.balance.value.balance
                    : account.address.address.balance.value.balance,
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
