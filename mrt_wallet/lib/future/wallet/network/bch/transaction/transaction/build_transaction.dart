import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/cotnroller/bitcoin_operation.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/cotnroller/transaction_controller.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/transaction/token_builder.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/transaction/token_operation_view.dart';
import 'package:mrt_wallet/future/wallet/network/bch/token/pages/cash_token_info.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/transaction/pages/ordering/transaction_ordering_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class BitcoinCashBuildTransactionView extends StatelessWidget {
  const BitcoinCashBuildTransactionView({super.key, required this.controller});
  final BitcoinCashStateController controller;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("spendable_amount".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: AnimatedSwitcher(
              duration: APPConst.animationDuraion,
              child: Row(
                key: ValueKey(controller.spendableAmount.price),
                children: [
                  Expanded(
                    child: CoinPriceView(
                        key: ValueKey(controller.spendableAmount.price),
                        balance: controller.spendableAmount,
                        token: controller.network.coinParam.token,
                        style: context.onPrimaryTextTheme.titleMedium,
                        symbolColor: context.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          WidgetConstant.height20,
          Text("create_tokens".tr, style: context.textTheme.titleMedium),
          Text("amount_for_each_output".tr),
          WidgetConstant.height8,
          ...List.generate(
            controller.buildedTokens.length,
            (index) {
              final token = controller.buildedTokens[index];
              return ContainerWithBorder(
                onRemoveIcon: Icon(Icons.remove_circle,
                    color: context.onPrimaryContainer),
                onRemove: () {
                  controller.onRemoveBuildedToken(token);
                },
                child: BCHCashTokenDetailsView(
                    token: token.token, color: context.onPrimaryContainer),
              );
            },
          ),
          ContainerWithBorder(
            onRemoveIcon:
                Icon(Icons.add_box, color: context.onPrimaryContainer),
            onRemove: () {
              controller.onBuildToken(
                  (utxos) => context.openSliverBottomSheet("",
                      bodyBuilder: (sc) => BchCashTokenBuilderView(
                          scrollController: sc,
                          utxos: utxos,
                          account: controller.chainAccount)), () {
                context.showAlert("bch_token_index_zero_error".tr);
              });
            },
            child: Text("tap_to_create_token".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          ),
          if (controller.tokenOperation.isNotEmpty) ...[
            WidgetConstant.height20,
            Text("tokens".tr, style: context.textTheme.titleMedium),
            Text("add_operation_for_each_token".tr),
            WidgetConstant.height8,
            ...List.generate(controller.tokenOperation.length, (index) {
              final op = controller.tokenOperation[index];
              return ContainerWithBorder(
                validate: op.isComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: BCHCashTokenDetailsView(
                          token: op.cashToken,
                          color: context.colors.onPrimaryContainer,
                        )),
                        if (op.isComplete)
                          IconButton(
                              onPressed: () {
                                controller.onUpdateOperations(
                                    op,
                                    (p0) async => context.openSliverBottomSheet<
                                            BitcoinCashTransactionTokenOperation>(
                                        "token_operation".tr,
                                        child: TokenCashOperationView(
                                          token: p0,
                                          account: controller.chainAccount,
                                          network:
                                              controller.network.toNetwork(),
                                          remindAmount:
                                              controller.remindAmount.balance +
                                                  (op.totalAmount.balance),
                                        )));
                              },
                              icon: const Icon(Icons.edit))
                      ],
                    ),
                    Divider(color: context.colors.onPrimaryContainer),
                    _CompleteTokenCashOperationView(
                      operation: op,
                      network: controller.network,
                      onTapOperation: () {
                        controller.onUpdateOperations(
                            controller.tokenOperation[index],
                            (p0) async => context.openSliverBottomSheet<
                                    BitcoinCashTransactionTokenOperation>(
                                "token_operation".tr,
                                child: TokenCashOperationView(
                                  token: p0,
                                  account: controller.chainAccount,
                                  network: controller.network
                                      as WalletBitcoinCashNetwork,
                                  remindAmount:
                                      controller.remindAmount.balance +
                                          (op.totalAmount.balance),
                                )));
                      },
                    ),
                  ],
                ),
              );
            })
          ],
          WidgetConstant.height20,
          Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
          Text("amount_for_each_output".tr),
          WidgetConstant.height8,
          Column(
            children: List.generate(controller.receivers.length, (index) {
              final BitcoinOutputWithBalance receiver =
                  controller.receivers[index];
              return ContainerWithBorder(
                iconAlginment: CrossAxisAlignment.start,
                onRemoveIcon: const Icon(Icons.remove_circle),
                validate: receiver.hasAmount,
                onRemove: () {
                  controller.removeReceiver(receiver.address);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerWithBorder(
                        backgroundColor: context.onPrimaryContainer,
                        child: ReceiptAddressDetailsView(
                            address: receiver.address,
                            color: context.primaryContainer)),
                    ContainerWithBorder(
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigInt>(
                          "setup_output_amount".tr,
                          initialExtend: 1,
                          child: SetupNetworkAmount(
                            token: controller.network.coinParam.token,
                            max: controller.remindAmount.balance +
                                receiver.balance.balance,
                            min: controller.minimumOutput,
                            subtitle: PageTitleSubtitle(
                                title: "receiver".tr,
                                body: ReceiptAddressView(
                                    address: receiver.address)),
                          ),
                        )
                            .then((amount) {
                          controller.setupAccountAmount(receiver, amount);
                        });
                      },
                      validate: receiver.hasAmount,
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.primaryContainer),
                      backgroundColor: context.onPrimaryContainer,
                      child: CoinPriceView(
                          balance: receiver.balance,
                          token: controller.network.coinParam.token,
                          style: context.primaryTextTheme.titleMedium,
                          symbolColor: context.primaryContainer),
                    )
                  ],
                ),
              );
            }),
          ),
          ContainerWithBorder(
            validate: controller.tokenOperation.isNotEmpty ||
                controller.receivers.isNotEmpty,
            onRemove: () {
              context
                  .openSliverBottomSheet<
                          List<ReceiptAddress<BitcoinBaseAddress>>>(
                      "receiver_address".tr,
                      bodyBuilder: (c) =>
                          SelectRecipientAccountView<BitcoinBaseAddress>(
                            account: controller.chainAccount,
                            scrollController: c,
                            multipleSelect: true,
                          ),
                      maxExtend: 1,
                      minExtent: 0.8,
                      initialExtend: 0.9)
                  .then(
                (value) {
                  controller.onAddRecever(
                    value,
                    () {
                      context.showAlert("some_addresses_exist".tr);
                    },
                  );
                },
              );
            },
            onRemoveIcon:
                Icon(Icons.add_box, color: context.onPrimaryContainer),
            child: Text("tap_to_add_new_receipment".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          ),
          WidgetConstant.height20,
          Text("remaining_amount".tr, style: context.textTheme.titleMedium),
          Text("remaining_amount_and_receiver".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CoinPriceView(
                    balance: controller.remindAmount,
                    token: controller.network.coinParam.token,
                    symbolColor: context.primaryContainer,
                    style: context.primaryTextTheme.titleMedium,
                    showTokenImage: true,
                  )),
              ContainerWithBorder(
                validate: !controller.remindAmount.isNegative,
                onRemoveIcon: Icon(Icons.edit, color: context.primaryContainer),
                backgroundColor: context.onPrimaryContainer,
                validateText: "transaction_Insufficient_balance".tr,
                onRemove: () {
                  context
                      .openSliverBottomSheet<ChainAccount>(
                        "select_account".tr,
                        child: SwitchOrSelectAccountView(
                          account: controller.chainAccount,
                          showMultiSig: true,
                        ),
                        minExtent: 0.5,
                        maxExtend: 0.9,
                        initialExtend: 0.7,
                        centerContent: false,
                      )
                      .then(controller.changeAccount);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.onChangeAddress.type.value,
                        style: context.primaryTextTheme.labelLarge),
                    OneLineTextWidget(controller.onChangeAddressView,
                        style: context.primaryTextTheme.bodyMedium)
                  ],
                ),
              ),
            ],
          )),
          WidgetConstant.height20,
          Text("replace_by_fee".tr, style: context.textTheme.titleMedium),
          Text("rbf_desc".tr),
          WidgetConstant.height8,
          InkWell(
            borderRadius: WidgetConstant.border8,
            onTap: () {
              controller.toggleRbf(false);
            },
            child: ContainerWithBorder(
                child: Row(
              children: [
                Expanded(
                  child: Text(
                    "replace_by_fee".tr,
                    style:
                        context.colors.onPrimaryContainer.bodyMedium(context),
                  ),
                ),
                Switch(value: controller.rbf, onChanged: controller.toggleRbf),
              ],
            )),
          ),
          WidgetConstant.height20,
          Text("setup_memo".tr, style: context.textTheme.titleMedium),
          Text("memo_desc2".tr),
          WidgetConstant.height8,
          WidgetConstant.height8,
          ...List.generate(controller.memoScripts.length, (index) {
            final memo = controller.memoScripts[index];
            return ContainerWithBorder(
                onRemoveIcon: Icon(Icons.remove_circle,
                    color: context.onPrimaryContainer),
                onRemove: memo.removable
                    ? () {
                        controller.onRemoveMemo(memo);
                      }
                    : null,
                child: Text(memo.memo,
                    style: context.onPrimaryTextTheme.bodyMedium));
          }),
          ContainerWithBorder(
              onRemoveIcon:
                  Icon(Icons.add_box, color: context.onPrimaryContainer),
              onRemove: () {
                controller.onTapMemo(() async {
                  final result = await context.openSliverBottomSheet<String>(
                    "transaction_memo".tr,
                    child: StringWriterView(
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
              child: Text("tap_to_add_memo".tr,
                  style:
                      context.colors.onPrimaryContainer.bodyMedium(context))),
          WidgetConstant.height20,
          Text("transaction_ordering".tr, style: context.textTheme.titleMedium),
          Text("transaction_ordering_desc".tr),
          ContainerWithBorder(
              child: AppDropDownBottom(
            contentPadding: EdgeInsets.zero,
            key: ValueKey(controller.ordering),
            fillColor: context.colors.transparent,
            items: {
              for (final i in TransactionOrdering.values)
                i: Text(i.name.tr, style: context.onPrimaryTextTheme.bodyMedium)
            },
            itemBuilder: {
              for (final i in TransactionOrdering.values)
                i: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.name.tr),
                    Text(i.desc.tr, style: context.textTheme.bodySmall)
                  ],
                )
            },
            value: controller.ordering,
            onChanged: (p0) {
              controller.onChangeOrdering(p0, (p0, p1) async {
                return context.openSliverBottomSheet("transaction_ordering".tr,
                    bodyBuilder: (c) => TransactionOrderingView(
                          inputs: p0,
                          outputs: p1,
                          network: controller.network,
                        ),
                    minExtent: 0.9,
                    maxExtend: 1,
                    initialExtend: 0.9);
              });
            },
          )),
          WidgetConstant.height20,
          Text("transaction_fee".tr, style: context.textTheme.titleMedium),
          Text("cost_for_transaction".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            validateText: controller.feeError?.tr,
            validate: controller.feeError == null,
            onRemove: () {
              context
                  .openSliverBottomSheet<(String?, BigInt?)>(
                "transaction_fee".tr,
                child: SetupTransactionFee(
                  fees: controller.fees,
                  network: controller.network,
                  type: controller.feeRateType?.name,
                  max: controller.sumOfSelectedUtxo.balance,
                  customFee: controller.transactionFee.balance,
                ),
              )
                  .then((value) {
                controller.setFee(value?.$1, customFee: value?.$2);
              });
            },
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.feeRateType?.name.camelCase ?? "custom_fee".tr,
                    style: context.onPrimaryTextTheme.labelLarge),
                CoinPriceView(
                    balance: controller.transactionFee,
                    token: controller.network.coinParam.token,
                    style: context.onPrimaryTextTheme.titleMedium,
                    symbolColor: context.onPrimaryContainer),
                if (controller.feePerByteDesc != null)
                  Text(controller.feePerByteDesc ?? '',
                      style: context.onPrimaryTextTheme.bodySmall)
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: controller.trReady
                    ? () {
                        controller.sendTransaction();
                      }
                    : null,
                child: Text("send_transaction".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _CompleteTokenCashOperationView extends StatefulWidget {
  const _CompleteTokenCashOperationView(
      {required this.operation,
      required this.network,
      required this.onTapOperation});
  final BitcoinCashTransactionTokenOperation operation;
  final WalletNetwork network;
  final DynamicVoid onTapOperation;

  @override
  State<_CompleteTokenCashOperationView> createState() =>
      _CompleteTokenCashOperationViewState();
}

class _CompleteTokenCashOperationViewState
    extends State<_CompleteTokenCashOperationView> {
  bool showAll = false;
  void toggleShow() {
    showAll = !showAll;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.operation.isComplete) {
      return ContainerWithBorder(
        onRemoveIcon: Icon(Icons.add_box, color: context.primaryContainer),
        backgroundColor: context.onPrimaryContainer,
        onRemove: widget.onTapOperation,
        child: Text("tap_to_add_operation".tr,
            style: context.primaryTextTheme.bodyMedium),
      );
    }
    final op = widget.operation.operation;
    final BCHCashToken token = widget.operation.cashToken;
    final bool hasAmount = token.cashToken.hasAmount;
    return ContainerWithBorder(
        onRemove: toggleShow,
        backgroundColor: context.onPrimaryContainer,
        enableTap: true,
        iconAlginment:
            showAll ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        onRemoveWidget: showAll
            ? Icon(Icons.arrow_drop_down, color: context.primaryContainer)
            : Icon(Icons.arrow_drop_up, color: context.primaryContainer),
        child: AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: SizedBox(
            width: context.mediaQuery.size.width,
            key: ValueKey<bool>(showAll),
            child: ConditionalWidgets(enable: showAll, widgets: {
              true: (context) {
                return ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final receiver = op[index].receiver;
                      final CashToken token = receiver.token!;
                      final bool hasReceiverAmount = token.hasAmount;
                      final operation = op[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!operation.isBurnable)
                            ContainerWithBorder(
                                child: ReceiptAddressDetailsView(
                                    address: receiver.address,
                                    color: context.onPrimaryContainer))
                          else
                            ErrorTextContainer(
                              error: "burn".tr,
                              showErrorIcon: true,
                              enableTap: false,
                            ),
                          if (!operation.isBurnable)
                            ContainerWithBorder(
                              child: CoinPriceView(
                                token: widget.network.coinParam.token,
                                balance: receiver.balance,
                                style: context.onPrimaryTextTheme.titleMedium,
                                symbolColor: context.onPrimaryContainer,
                                showTokenImage: true,
                              ),
                            ),
                          if (hasReceiverAmount)
                            ContainerWithBorder(
                              child: CoinPriceView(
                                token: widget.operation.token,
                                balance: receiver.tokenBalance,
                                style: context.onPrimaryTextTheme.titleMedium,
                                symbolColor: context.onPrimaryContainer,
                                showTokenImage: true,
                              ),
                            ),
                          if (token.hasCommitment)
                            ContainerWithBorder(
                              child: CopyableTextWidget(
                                  text: token.commitmentInHex!,
                                  color: context.onPrimaryContainer),
                            )
                        ],
                      );
                    },
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemCount: op.length);
              },
              false: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasAmount) ...[
                        CoinPriceView(
                            token: widget.operation.token,
                            balance: widget.operation.totalTokenAmount,
                            style: context.primaryTextTheme.titleMedium,
                            symbolColor: context.primaryContainer,
                            showTokenImage: true),
                        Divider(color: context.primaryContainer),
                      ],
                      CoinPriceView(
                        token: widget.network.coinParam.token,
                        balance: widget.operation.totalAmount,
                        style: context.primaryTextTheme.titleMedium,
                        symbolColor: context.primaryContainer,
                        showTokenImage: true,
                      ),
                    ],
                  ),
            }),
          ),
        ));
  }
}
