import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/cotnroller/bitcoin_operation.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/bitcoin_cash/bitcoin_cash_utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class TokenCashOperationView extends StatefulWidget {
  const TokenCashOperationView(
      {super.key,
      required this.token,
      required this.account,
      required this.network,
      required this.remindAmount});
  final BitcoinCashTransactionTokenOperation token;
  final BitcoinChain account;
  final WalletBitcoinCashNetwork network;
  final BigInt remindAmount;

  @override
  State<TokenCashOperationView> createState() => _TokenCashOperationViewState();
}

class _TokenCashOperationViewState extends State<TokenCashOperationView>
    with SafeState {
  final Map<String, BitcoinCashTokenOperation> _receivers = {};
  late final IntegerBalance remindAmount;
  late final IntegerBalance remindTokenAmount;
  late final BCHCashToken token = widget.token.cashToken;
  bool get haveBurnaleOutput =>
      _receivers.containsKey(token.cashToken.category);
  bool get haveAnyOutput =>
      _receivers.values.where((element) => !element.isBurnable).isNotEmpty;
  late final bool isImMutable = token.cashToken.hasNFT &&
      token.cashToken.capability == CashTokenCapability.noCapability;
  late final bool isMutable = token.cashToken.hasNFT &&
      token.cashToken.capability == CashTokenCapability.mutable;
  String? selected;

  @override
  void initState() {
    remindAmount =
        IntegerBalance(widget.remindAmount, widget.network.coinParam.decimal);
    remindTokenAmount =
        IntegerBalance(token.cashToken.amount, widget.token.token.decimal!);
    for (final i in widget.token.operation) {
      if (i.isBurnable) {
        i as BurnableBitcoinCashTokenOperation;
        _receivers.addAll({
          token.cashToken.category:
              BurnableBitcoinCashTokenOperation(receiver: i.receiver.copyWith())
        });
      } else {
        _receivers.addAll({
          i.receiver.viewAddress:
              SpendBitcoinCashTokenOperation(receiver: i.receiver.copyWith())
        });
      }
    }

    calculateRemindAmounts();
    super.initState();
  }

  List<BitcoinCashTokenOperation> get receivers => _receivers.values.toList();
  bool isReady = false;

  void onAddRecever(ReceiptAddress<BitcoinBaseAddress>? addr) {
    if (addr == null) return;
    final toAddr = addr.networkAddress
        .toAddress(widget.network.coinParam.transacationNetwork);
    if (_receivers.containsKey(toAddr) && !token.cashToken.hasNFT) {
      return;
    } else {
      final SpendBitcoinCashTokenOperation operation =
          SpendBitcoinCashTokenOperation(
              receiver: BitcoinOutputWithBalance(
                  address: addr,
                  network: widget.network,
                  token: token.cashToken));
      _receivers[toAddr] = operation;
      if (isImMutable) {
        operation.receiver.tokenBalance?.updateBalance(token.cashToken.amount);
        calculateRemindAmounts();
      }
    }
    selected = toAddr;
    setState(() {});
  }

  void onRemoveReceiver(String address) {
    _receivers.remove(address);
    calculateRemindAmounts();
  }

  void calculateRemindAmounts() {
    final spendAmount = _receivers.values.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.networkAmount);
    remindAmount.updateBalance(widget.remindAmount - spendAmount);
    if (token.cashToken.hasAmount) {
      final spendToken = _receivers.values.fold(BigInt.zero,
          (previousValue, element) => previousValue + element.tokenAmount);
      remindTokenAmount.updateBalance(token.cashToken.amount - spendToken);
    }
    bool receiversIsReady = receivers.isEmpty ||
        _receivers.values.any((element) => !element.isReady);
    isReady = (!remindAmount.isNegative && remindTokenAmount.isZero) &&
        !receiversIsReady;
    setState(() {});
  }

  void setupAccountAmount(String address, BigInt? amount) {
    if (amount == null) return;
    BitcoinCashTokenOperation operation = _receivers[address]!;
    operation as SpendBitcoinCashTokenOperation;
    operation.receiver.balance.updateBalance(amount);
    calculateRemindAmounts();
  }

  void setupTokenAmount(String address, BigInt? amount) {
    if (amount == null || isImMutable) return;
    _receivers[address]!.receiver.tokenBalance?.updateBalance(amount);
    calculateRemindAmounts();
  }

  void onSetupOperation() {
    if (!isReady) return;
    final transactionOperation = widget.token.copyWith(
        operation: _receivers.values.map((e) => e.copyWith()).toList());
    context.pop(transactionOperation);
  }

  void onChangeCapability(String? addres, CashTokenCapability? capability) {
    if (capability == null || !_receivers.containsKey(addres) || isImMutable) {
      return;
    }
    if (isMutable && capability == CashTokenCapability.minting) {
      context.showAlert("bch_nft_wrong_capability".tr);
      setState(() {});
      return;
    }
    BitcoinCashTokenOperation operation = _receivers[addres]!;
    operation as SpendBitcoinCashTokenOperation;
    BitcoinOutputWithBalance receiver = operation.receiver;
    receiver = receiver.copyWith(
        token: receiver.token?.copyWith(
            bitfield: CashTokenUtils.buildBitfield(
                hasAmount: token.cashToken.hasAmount,
                capability: capability,
                hasNFT: true,
                hasCommitmentLength: receiver.token!.hasCommitment)));
    _receivers[addres!] = SpendBitcoinCashTokenOperation(receiver: receiver);
    calculateRemindAmounts();
  }

  String? commitmentValidate(String? v) {
    if (BCHUtils.commitmentValidate(v)) {
      return null;
    }
    return "commitment_validate_desc".tr;
  }

  void onUpdateCommitment(String? address, String? commitment) {
    if (address == null || !_receivers.containsKey(address) || isImMutable) {
      return;
    }
    final String? correctCommitment =
        (commitment?.isEmpty ?? true) ? null : commitment;
    BitcoinCashTokenOperation operation = _receivers[address]!;
    operation as SpendBitcoinCashTokenOperation;
    final receiver = operation.receiver.copyWith(
        token: operation.receiver.token?.copyWith(
            commitment: correctCommitment == null
                ? null
                : StringUtils.toBytes(correctCommitment),
            bitfield: CashTokenUtils.buildBitfield(
                hasAmount: token.cashToken.hasAmount,
                capability: token.cashToken.capability,
                hasNFT: true,
                hasCommitmentLength: correctCommitment != null)));
    _receivers[address] = SpendBitcoinCashTokenOperation(receiver: receiver);
    calculateRemindAmounts();
  }

  void onSelect(String addr) {
    if (selected == addr) {
      selected = null;
    } else {
      selected = addr;
    }
    setState(() {});
  }

  void onAddBurnOperantion() {
    final BurnableBitcoinCashTokenOperation operation =
        BurnableBitcoinCashTokenOperation(
            receiver: BitcoinBurnableUtxoWithBalance(
                token: token.cashToken, categoryId: token.cashToken.category));
    _receivers[token.cashToken.category] = operation;
    if (isImMutable) {
      operation.receiver.tokenBalance?.updateBalance(token.cashToken.amount);
    }
    selected = token.cashToken.category;
    calculateRemindAmounts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "token_operation".tr,
            body: ContainerWithBorder(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(token.cashToken.category),
                Divider(
                  color: context.colors.onPrimaryContainer,
                ),
                if (token.cashToken.hasNFT)
                  Row(
                    children: [
                      RichText(
                          text: TextSpan(
                              style: context.textTheme.bodyMedium,
                              children: [
                            TextSpan(text: "nft".tr),
                            const TextSpan(text: "-"),
                            TextSpan(text: token.cashToken.capability!.name.tr),
                          ])),
                      if (token.cashToken.hasCommitment) ...[
                        WidgetConstant.width8,
                        Flexible(
                            child: OneLineTextWidget(
                                token.cashToken.commitmentInHex ?? ""))
                      ],
                    ],
                  ),
                if (token.cashToken.hasAmount)
                  CoinPriceView(
                      token: widget.token.token,
                      balance: widget.token.cashToken.balance,
                      style: context.textTheme.titleLarge),
              ],
            ))),
        Text("list_of_operations".tr, style: context.textTheme.titleMedium),
        Text("initiate_operations".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(receivers.length, (index) {
            final address = _receivers.keys.toList()[index];
            final bool isSelected = address == selected;
            final receiver = receivers[index].receiver;
            final operation = receivers[index];
            return ContainerWithBorder(
              validate: receivers[index].isReady,
              iconAlginment: CrossAxisAlignment.start,
              child: AnimatedSize(
                duration: APPConst.animationDuraion,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => onSelect(address),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                                operation.isBurnable
                                    ? "burn".tr
                                    : "recipient".tr,
                                style: context.textTheme.titleMedium),
                          ),
                          IconButton(
                              onPressed: () => onSelect(address),
                              icon: isSelected
                                  ? const Icon(Icons.arrow_drop_up)
                                  : const Icon(Icons.arrow_drop_down))
                        ],
                      ),
                    ),
                    !isSelected
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ContainerWithBorder(
                                backgroundColor: context.colors.secondary,
                                onRemoveIcon: Icon(Icons.remove_circle,
                                    color: context.colors.onSecondary),
                                onRemove: () {
                                  onRemoveReceiver(address);
                                },
                                onTapWhenOnRemove: false,
                                child: operation.isBurnable
                                    ? OneLineTextWidget(
                                        token.cashToken.category,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                                color:
                                                    context.colors.onSecondary),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              receiver.address.networkAddress
                                                  .type.value,
                                              style: context
                                                  .textTheme.labelLarge
                                                  ?.copyWith(
                                                      color: context
                                                          .colors.onSecondary)),
                                          OneLineTextWidget(
                                            receiver.viewAddress,
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: context
                                                        .colors.onSecondary),
                                          ),
                                        ],
                                      ),
                              )
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!operation.isBurnable) ...[
                                ContainerWithBorder(
                                  backgroundColor: context.colors.secondary,
                                  onRemoveIcon: Icon(Icons.remove_circle,
                                      color: context.colors.onSecondary),
                                  onRemove: () {
                                    onRemoveReceiver(address);
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          receiver.address.networkAddress.type
                                              .value,
                                          style: context.textTheme.labelLarge
                                              ?.copyWith(
                                                  color: context
                                                      .colors.onSecondary)),
                                      OneLineTextWidget(
                                        receiver.viewAddress,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                                color:
                                                    context.colors.onSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Text("amount".tr,
                                    style: context.textTheme.titleMedium),
                                Text("t_amount".tr.replaceOne(
                                    widget.network.coinParam.token.symbol)),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  backgroundColor: context.colors.secondary,
                                  onRemoveIcon: receiver.hasAmount
                                      ? Icon(Icons.edit,
                                          color: context.colors.onSecondary)
                                      : Icon(Icons.add_box,
                                          color: context.colors.onSecondary),
                                  validate: receiver.hasAmount,
                                  onRemove: () {
                                    context
                                        .openSliverBottomSheet<BigInt>(
                                      "setup_output_amount".tr,
                                      child: SetupNetworkAmount(
                                        token: widget.network.coinParam.token,
                                        max: remindAmount.balance +
                                            receiver.balance.balance,
                                        min: BCHUtils.minimumSatoshiTokenOutput,
                                        subtitle: PageTitleSubtitle(
                                            title: "receiver".tr,
                                            body: ContainerWithBorder(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    receiver
                                                        .address
                                                        .networkAddress
                                                        .type
                                                        .value,
                                                    style: context
                                                        .textTheme.labelLarge),
                                                OneLineTextWidget(
                                                    receiver.viewAddress)
                                              ],
                                            ))),
                                      ),
                                    )
                                        .then((amount) {
                                      if (context.mounted) {
                                        setupAccountAmount(
                                            receiver.viewAddress, amount);
                                      }
                                    });
                                  },
                                  child: CoinPriceView(
                                    balance: receiver.balance,
                                    token: widget.network.coinParam.token,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(
                                            color: context.colors.onSecondary),
                                    symbolColor: context.colors.onSecondary,
                                  ),
                                ),
                              ] else
                                ContainerWithBorder(
                                    backgroundColor: context.colors.secondary,
                                    onRemoveIcon: Icon(Icons.remove_circle,
                                        color: context.colors.onSecondary),
                                    onRemove: () {
                                      onRemoveReceiver(address);
                                    },
                                    onTapWhenOnRemove: false,
                                    child: OneLineTextWidget(
                                      token.cashToken.category,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                              color:
                                                  context.colors.onSecondary),
                                    )),
                              if (token.cashToken.hasAmount) ...[
                                Text("token_amount".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  backgroundColor: context.colors.secondary,
                                  onRemoveIcon: receiver.hasTokenAmount
                                      ? Icon(Icons.edit,
                                          color: context.colors.onSecondary)
                                      : Icon(Icons.add_box,
                                          color: context.colors.onSecondary),
                                  validate: receiver.hasTokenAmount,
                                  onRemove: isImMutable
                                      ? null
                                      : () {
                                          context
                                              .openSliverBottomSheet<BigInt>(
                                            operation.isBurnable
                                                ? "burn_amount".tr
                                                : "setup_output_amount".tr,
                                            child: SetupNetworkAmount(
                                              token: widget.token.token,
                                              max: remindTokenAmount.balance +
                                                  receiver
                                                      .tokenBalance!.balance,
                                              min: BigInt.zero,
                                              subtitle: PageTitleSubtitle(
                                                  title: operation.isBurnable
                                                      ? "burn_amount".tr
                                                      : "receiver".tr,
                                                  body: operation.isBurnable
                                                      ? Text(
                                                          "setup_burnable_amount"
                                                              .tr)
                                                      : ContainerWithBorder(
                                                          child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                receiver
                                                                    .address
                                                                    .networkAddress
                                                                    .type
                                                                    .value,
                                                                style: context
                                                                    .textTheme
                                                                    .labelLarge),
                                                            OneLineTextWidget(
                                                                receiver
                                                                    .viewAddress)
                                                          ],
                                                        ))),
                                            ),
                                          )
                                              .then((amount) {
                                            if (context.mounted) {
                                              if (operation.isBurnable) {
                                                setupTokenAmount(
                                                    token.cashToken.category,
                                                    amount);
                                              } else {
                                                setupTokenAmount(
                                                    receiver.viewAddress,
                                                    amount);
                                              }
                                            }
                                          });
                                        },
                                  child: CoinPriceView(
                                    balance: receiver.tokenBalance,
                                    token: widget.token.token,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(
                                            color: context.colors.onSecondary),
                                    symbolColor: context.colors.onSecondary,
                                  ),
                                ),
                              ],
                              if (token.cashToken.hasNFT) ...[
                                Text("capability".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                    backgroundColor: context.colors.secondary,
                                    child: AppDropDownBottom(
                                      items: {
                                        for (final i
                                            in CashTokenCapability.values)
                                          i: Text(i.name.tr)
                                      },
                                      label: "capability".tr,
                                      value: receiver.token!.capability,
                                      key: UniqueKey(),
                                      onChanged:
                                          isImMutable || operation.isBurnable
                                              ? null
                                              : (p0) {
                                                  onChangeCapability(address,
                                                      p0 as CashTokenCapability?);
                                                },
                                    )),
                                Text("commitment".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  onRemoveIcon: Icon(Icons.edit,
                                      color: context.colors.onSecondary),
                                  onRemove: isImMutable || operation.isBurnable
                                      ? null
                                      : () {
                                          context
                                              .openSliverBottomSheet<String>(
                                            "update_commitment".tr,
                                            child: StringWriterView(
                                              defaultValue: receiver
                                                  .token?.commitmentInHex,
                                              maxLength:
                                                  RippleConst.maxDomainLength,
                                              customForm: commitmentValidate,
                                              title: PageTitleSubtitle(
                                                  title: "commitment".tr,
                                                  body: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          "commitment_desc".tr),
                                                      WidgetConstant.height8,
                                                      Text("empty_desc".tr)
                                                    ],
                                                  )),
                                              buttonText: "setup_input".tr,
                                              label: "commitment".tr,
                                            ),
                                          )
                                              .then(
                                            (value) {
                                              onUpdateCommitment(
                                                  address, value);
                                            },
                                          );
                                        },
                                  backgroundColor: context.colors.secondary,
                                  child: Text(
                                      receiver.token!.commitmentInHex ??
                                          (!isImMutable
                                              ? "tap_to_add_commitment".tr
                                              : "without_commitment".tr),
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                              color:
                                                  context.colors.onSecondary)),
                                )
                              ],
                            ],
                          ),
                  ],
                ),
              ),
            );
          }),
        ),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: isImMutable && _receivers.isNotEmpty
              ? WidgetConstant.sizedBox
              : Column(
                  children: [
                    if (isMutable && haveAnyOutput)
                      WidgetConstant.sizedBox
                    else
                      ContainerWithBorder(
                        onRemove: () {
                          context
                              .openSliverBottomSheet<
                                      ReceiptAddress<BitcoinBaseAddress>>(
                                  "receiver_address".tr,
                                  bodyBuilder: (c) =>
                                      SelectRecipientAccountView<
                                              BitcoinBaseAddress>(
                                          account: widget.account,
                                          scrollController: c),
                                  maxExtend: 1,
                                  minExtent: 0.8,
                                  initialExtend: 0.9)
                              .then(onAddRecever);
                        },
                        onRemoveIcon: const Icon(Icons.add_box),
                        child: Text("tap_to_add_operation".tr),
                      ),
                    if (!haveBurnaleOutput)
                      ContainerWithBorder(
                        onRemove: () {
                          onAddBurnOperantion();
                        },
                        onRemoveIcon: const Icon(Icons.add_box),
                        child: Text("tap_to_add_burn_operation".tr),
                      ),
                  ],
                ),
        ),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: remindTokenAmount.isZero
              ? WidgetConstant.sizedBox
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("remaining_amount".tr,
                        style: context.textTheme.titleMedium),
                    Text("remaining_token_amount_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      child: CoinPriceView(
                        balance: remindTokenAmount,
                        token: widget.token.token,
                        style: context.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: isReady ? onSetupOperation : null,
              child: Text("setup_operation".tr),
            )
          ],
        )
      ],
    );
  }
}
