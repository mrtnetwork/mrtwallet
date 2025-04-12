import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/bitcoin/addresses/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/bitcoin/models/models.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class BitcoinWeb3TransactionFieldsView extends StatelessWidget {
  const BitcoinWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3BitcoinRequest<String, Web3BitcoinRequestParam<String>> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
        showRequestAccount: true,
        controller: () => Web3BitcoinTransactionRequestController(
            walletProvider: wallet, request: request),
        builder: (context, controller) {
          return [
            switch (controller.request.params.method) {
              Web3BitcoinRequestMethods.sendTransaction => _SendTransactionView(
                  form: controller.form as Web3BitcoinSendTransactionForm),
              Web3BitcoinRequestMethods.signTransaction => _TransactionView(
                  form: controller.form as Web3BitcoinSignTransactionForm),
              _ => WidgetConstant.sliverSizedBox
            },
            WidgetConstant.sliverPaddingVertial40,
          ];
        },
        request: request);
  }
}

class _SendTransactionView extends StatelessWidget {
  final Web3BitcoinSendTransactionForm form;
  const _SendTransactionView({required this.form});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        WidgetConstant.height20,
        Text("utxos".tr, style: context.textTheme.titleMedium),
        Text("select_unspent_utxos_desc".tr),
        WidgetConstant.height8,
        APPAnimatedSwitcher(enable: form.hasUtxos, widgets: {
          true: (context) => ContainerWithBorder(
                onRemove: () {
                  form.updateUtxos(
                      (allUtxo, selectUtxos) => context.openDialogPage(
                            'label',
                            child: (context) => _SelectUtxos(
                                utxos: allUtxo,
                                network: form.network,
                                selectedUtxos: selectUtxos),
                          ));
                },
                onRemoveIcon:
                    Icon(Icons.edit, color: context.onPrimaryContainer),
                child:
                    _UtxoTotalSelected({form.network.token: form.totalSelect}),
              ),
          false: (context) => ContainerWithBorder(
                enableTap: true,
                validate: form.hasUtxos,
                onRemove: () {
                  form.updateUtxos(
                      (allUtxo, selectUtxos) => context.openDialogPage(
                            'label',
                            child: (context) => _SelectUtxos(
                                utxos: allUtxo,
                                network: form.network,
                                selectedUtxos: selectUtxos),
                          ));
                },
                onRemoveIcon:
                    Icon(Icons.add_box, color: context.onPrimaryContainer),
                child: Text("tap_to_choose_utxos".tr,
                    style: context.onPrimaryTextTheme.bodyMedium),
              )
        }),
        WidgetConstant.height20,
        Text("outputs".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        Column(
          children: List.generate(form.outputs.length, (index) {
            final output = form.outputs[index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConditionalWidget(
                      enable: output.address != null,
                      onDeactive: (context) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("script".tr,
                                  style:
                                      context.onPrimaryTextTheme.titleMedium),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                  backgroundColor: context.onPrimaryContainer,
                                  child: CopyableTextWidget(
                                      text: output.script,
                                      maxLines: 3,
                                      color: context.primaryContainer)),
                              ConditionalWidget(
                                  enable: output.opReturns != null,
                                  onActive: (context) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            WidgetConstant.height20,
                                            Text("content".tr,
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .titleMedium),
                                            WidgetConstant.height8,
                                            ContainerWithBorder(
                                                backgroundColor:
                                                    context.onPrimaryContainer,
                                                child: CopyableTextWidget(
                                                    text: output.opReturns!,
                                                    maxLines: 3,
                                                    color: context
                                                        .primaryContainer)),
                                          ]))
                            ]);
                      },
                      onActive: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("recipient".tr,
                                    style:
                                        context.onPrimaryTextTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                    backgroundColor: context.onPrimaryContainer,
                                    onRemove: output.change ? () {} : null,
                                    enableTap: false,
                                    onRemoveIcon: TappedTooltipView(
                                        tooltipWidget: ToolTipView(
                                      message:
                                          "amount_will_be_returned_back_to_account"
                                              .tr,
                                      child: Icon(Icons.change_circle_outlined,
                                          color: context.primaryContainer),
                                    )),
                                    child: ReceiptAddressDetailsView(
                                        address: output.address!,
                                        color: context.primaryContainer))
                              ])),
                  ContainerWithBorder(
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinPriceView(
                        balance: output.balance,
                        token: form.network.token,
                        style: context.primaryTextTheme.titleMedium,
                        symbolColor: context.primaryContainer),
                  )
                ],
              ),
            );
          }),
        ),
        ConditionalWidget(
            enable: form.remainderAmount.largerThanZero,
            onActive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("remaining_amount".tr,
                        style: context.textTheme.titleMedium),
                    Text("remaining_amount_and_receiver".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            child: CoinPriceView(
                              balance: form.remainderAmount,
                              token: form.network.token,
                              symbolColor: context.primaryContainer,
                              style: context.primaryTextTheme.titleMedium,
                              showTokenImage: true,
                            )),
                        ContainerWithBorder(
                          // validate: !form.change.balance.isNegative,
                          onRemoveIcon:
                              Icon(Icons.edit, color: context.primaryContainer),
                          backgroundColor: context.onPrimaryContainer,
                          validateText: "transaction_Insufficient_balance".tr,
                          onRemove: () {
                            context
                                .openSliverBottomSheet<IBitcoinAddress>(
                                  "select_account".tr,
                                  child: SwitchOrSelectAccountView(
                                    account: form.account,
                                    showMultiSig: true,
                                  ),
                                  centerContent: false,
                                )
                                .then(form.onChangeRemainderAccount);
                          },
                          child: AddressDetailsView(
                              address: form.change,
                              color: context.primaryContainer),
                        ),
                      ],
                    )),
                  ],
                )),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("cost_for_transaction".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validateText: () {
            if (!form.hasNetworkFee) {
              return "setup_fee_manually".tr;
            }
            return null;
          }(),
          validate: form.fee.largerThanZero,
          onRemove: () {
            form.changeFee((fees, type, fee) =>
                context.openSliverBottomSheet<(String?, BigInt?)>(
                  "transaction_fee".tr,
                  child: SetupTransactionFee(
                      fees: fees,
                      network: form.network,
                      type: type,
                      customFee: fee,
                      max: form.balance),
                ));
          },
          onRemoveIcon: const Icon(Icons.edit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(form.feeRateType.name.tr,
                  style: context.onPrimaryTextTheme.labelLarge),
              Divider(color: context.onPrimaryContainer),
              CoinPriceView(
                balance: form.fee,
                token: form.network.coinParam.token,
                style: context.onPrimaryTextTheme.titleMedium,
                symbolColor: context.onPrimaryContainer,
              ),
              if (form.feePerByte != null)
                Text(form.feePerByte ?? '',
                    style: context.onPrimaryTextTheme.bodySmall)
            ],
          ),
        ),
        InsufficientBalanceErrorView(
            token: form.network.token, balance: form.insufficientBalances),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                activePress: form.isReady,
                padding: WidgetConstant.paddingVertical40,
                onPressed: () {
                  form.sendTransaction();
                },
                child: Text("send_transaction".tr)),
          ],
        )
      ]),
    );
  }
}

class _SelectUtxos extends StatefulWidget {
  const _SelectUtxos({
    required this.utxos,
    required this.selectedUtxos,
    required this.network,
  });
  final List<BitcoinAccountWithUtxos> utxos;
  final List<BitcoinUtxoWithBalance> selectedUtxos;
  final WalletBitcoinNetwork network;

  @override
  State<_SelectUtxos> createState() => __SelectUtxosState();
}

class __SelectUtxosState extends State<_SelectUtxos>
    with SafeState<_SelectUtxos> {
  Map<Token, IntegerBalance> totalSelect = {};
  List<BitcoinAccountWithUtxos> utxos = [];
  WalletBitcoinNetwork get network => widget.network;
  late final int totalUtxos =
      utxos.fold<int>(0, (p, c) => p + c.utxosWithBalance.length);
  List<BitcoinUtxoWithBalance> selectedutxos = [];
  void onAddUtxo(BitcoinUtxoWithBalance utxo) {
    final r = selectedutxos.remove(utxo);
    if (!r) {
      selectedutxos.add(utxo);
    }
    updateAmount();
    updateState();
  }

  void chooseAll() {
    if (isSelectAll) {
      selectedutxos = [];
    } else {
      selectedutxos =
          utxos.map((e) => e.utxosWithBalance).expand((e) => e).toList();
      updateAmount();
    }

    updateState();
  }

  void updateAmount() {
    for (final i in totalSelect.values) {
      i.zero();
    }
    final amounts =
        selectedutxos.fold(BigInt.zero, (p, c) => p + c.balance.balance);
    totalSelect[network.token]?.updateBalance(amounts);
    for (final i in selectedutxos) {
      final token = i.cashToken?.token;
      if (token == null) continue;
      totalSelect[token]?.addAmount(i.cashToken?.balance.balance);
    }
  }

  bool get isSelectAll => totalUtxos == selectedutxos.length;
  void _init() {
    utxos = widget.utxos.where((e) => e.utxosWithBalance.isNotEmpty).toList();
    selectedutxos = widget.selectedUtxos.clone();
    totalSelect[network.token] = IntegerBalance.zero(network.coinDecimal);
    final allUtxos =
        utxos.map((e) => e.utxosWithBalance).expand((e) => e).toList();
    for (final i in allUtxos) {
      final token = i.cashToken?.token;
      if (token == null) continue;
      totalSelect[token] ??= IntegerBalance.zero(0);
    }
    updateAmount();
  }

  void setupUtxos() {
    context.pop(selectedutxos);
  }

  @override
  void safeDispose() {
    super.safeDispose();
    totalSelect = {};
    selectedutxos = [];
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: setupUtxos,
        label: Text('setup_utxos'.tr),
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            centerTitle: false,
            title: Text("choose_utxos".tr),
            actions: [
              TextButton.icon(
                onPressed: chooseAll,
                label: Text('toggle_all'.tr),
                icon: APPAnimatedSwitcher(enable: isSelectAll, widgets: {
                  true: (context) => Icon(Icons.check_box_outlined),
                  false: (context) =>
                      Icon(Icons.check_box_outline_blank_rounded)
                }),
              ),
              TappedTooltipView(
                  tooltipWidget: ToolTipView(
                      tooltipWidget: (context) => TooltipConstrainsWidget(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('total_selected_utxos'.tr,
                                  style: context.textTheme.titleMedium),
                              WidgetConstant.height8,
                              IgnorePointer(
                                  child: _UtxoTotalSelected(totalSelect)),
                            ],
                          )),
                      child: IgnorePointer(
                        child: IconButton(
                            onPressed: () {}, icon: Icon(Icons.info)),
                      ))),
            ],
          ),
          SliverConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            sliver: EmptyItemSliverWidgetView(
              isEmpty: utxos.isEmpty,
              itemBuilder: () => SliverMainAxisGroup(slivers: [
                SliverList.separated(
                    itemCount: utxos.length,
                    itemBuilder: (context, index) {
                      final address = utxos[index];
                      return APPExpansionListTile(
                        title: AddressDetailsView(address: address.address),
                        initiallyExpanded: index == 0,
                        children: [
                          Column(
                            children: List.generate(
                                address.utxosWithBalance.length, (i) {
                              final utxo = address.utxosWithBalance[i];
                              return ContainerWithBorder(
                                backgroundColor: context.onPrimaryContainer,
                                enableTap: true,
                                onRemove: () => onAddUtxo(utxo),
                                onRemoveWidget: APPCheckBox(
                                  color: context.onPrimaryContainer,
                                  backgroundColor: context.primaryContainer,
                                  value: selectedutxos.contains(utxo),
                                  onChanged: (_) => onAddUtxo(utxo),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ContainerWithBorder(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CopyableTextWidget(
                                              text: utxo.txHash,
                                              color:
                                                  context.onPrimaryContainer),
                                          Divider(
                                              color:
                                                  context.onPrimaryContainer),
                                          CoinPriceView(
                                              token: widget.network.token,
                                              balance: utxo.balance,
                                              style: context.onPrimaryTextTheme
                                                  .titleMedium,
                                              symbolColor:
                                                  context.onPrimaryContainer,
                                              showTokenImage: true),
                                        ],
                                      ),
                                    ),
                                    if (utxo.cashToken != null)
                                      BCHCashTokenDetailsView(
                                          token: utxo.cashToken!,
                                          color: context.onPrimaryContainer),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, _) => WidgetConstant.divider),
              ]),
            ),
          ),
          WidgetConstant.sliverPaddingVertial40,
        ],
      ),
    );
  }
}

class _TransactionView extends StatelessWidget {
  const _TransactionView({required this.form});
  final Web3BitcoinSignTransactionForm form;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("total_input_amounts".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: CoinPriceView(
          token: form.network.token,
          balance: form.totalInput,
          style: context.onPrimaryTextTheme.titleMedium,
          symbolColor: context.onPrimaryContainer,
          showTokenImage: true,
        )),
        WidgetConstant.height20,
        Text("accounts".tr, style: context.textTheme.titleMedium),
        Text("inputs_from_your_accounts".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(form.accountInputs.length, (index) {
            final input = form.accountInputs[index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                          address: input.address,
                          color: context.primaryContainer)),
                  ContainerWithBorder(
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinPriceView(
                      balance: input.balance,
                      token: form.network.token,
                      style: context.primaryTextTheme.titleMedium,
                      symbolColor: context.primaryContainer,
                      showTokenImage: true,
                    ),
                  ),
                  ErrorTextContainer(
                      enableTap: false,
                      error: input.hasChangableOutput
                          ? "bitcoin_modifiable_sighash_warning".tr
                          : null),
                ],
              ),
            );
          }),
        ),
        WidgetConstant.height20,
        Text("outputs".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        Column(
          children: List.generate(form.outputs.length, (index) {
            final output = form.outputs[index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConditionalWidget(
                      enable: output.address != null,
                      onDeactive: (context) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("script".tr,
                                  style:
                                      context.onPrimaryTextTheme.titleMedium),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                  backgroundColor: context.onPrimaryContainer,
                                  child: CopyableTextWidget(
                                      text: output.script,
                                      maxLines: 3,
                                      color: context.primaryContainer)),
                              ConditionalWidget(
                                  enable: output.opReturns != null,
                                  onActive: (context) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            WidgetConstant.height20,
                                            Text("content".tr,
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .titleMedium),
                                            WidgetConstant.height8,
                                            ContainerWithBorder(
                                                backgroundColor:
                                                    context.onPrimaryContainer,
                                                child: CopyableTextWidget(
                                                    text: output.opReturns!,
                                                    maxLines: 3,
                                                    color: context
                                                        .primaryContainer)),
                                          ]))
                            ]);
                      },
                      onActive: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("recipient".tr,
                                    style:
                                        context.onPrimaryTextTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                    backgroundColor: context.onPrimaryContainer,
                                    onRemove: output.change ? () {} : null,
                                    enableTap: false,
                                    onRemoveIcon: TappedTooltipView(
                                        tooltipWidget: ToolTipView(
                                      message:
                                          "amount_will_be_returned_back_to_account"
                                              .tr,
                                      child: Icon(Icons.change_circle_outlined,
                                          color: context.primaryContainer),
                                    )),
                                    child: ReceiptAddressDetailsView(
                                        address: output.address!,
                                        color: context.primaryContainer))
                              ])),
                  ContainerWithBorder(
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinPriceView(
                        balance: output.balance,
                        token: form.network.token,
                        style: context.primaryTextTheme.titleMedium,
                        symbolColor: context.primaryContainer),
                  )
                ],
              ),
            );
          }),
        ),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("cost_for_transaction".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: CoinPriceView(
              balance: form.fee,
              token: form.network.coinParam.token,
              style: context.onPrimaryTextTheme.titleMedium,
              symbolColor: context.onPrimaryContainer),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: () {
                  form.signTransaction();
                },
                child: Text("sign_transactions".tr)),
          ],
        )
      ]),
    );
  }
}

class _UtxoTotalSelected extends StatelessWidget {
  const _UtxoTotalSelected(this.amounts);
  final Map<Token, IntegerBalance> amounts;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListView.separated(
        shrinkWrap: true,
        physics: WidgetConstant.noScrollPhysics,
        itemCount: amounts.length,
        separatorBuilder: (context, index) => WidgetConstant.divider,
        itemBuilder: (context, index) {
          final token = amounts.keys.toList()[index];
          final amount = amounts[token]!;
          return ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CoinPriceView(
              token: token,
              balance: amount,
              style: context.primaryTextTheme.bodyMedium,
              symbolColor: context.primaryContainer,
              showTokenImage: true,
            ),
          );
        },
      ),
    ]);
  }
}
