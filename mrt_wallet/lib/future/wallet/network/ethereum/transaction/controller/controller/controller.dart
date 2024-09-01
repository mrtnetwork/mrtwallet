import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class EthereumTransactionStateController extends EthTransactionImpl
    with ETHTransactionFeeImpl, ETHSignerImpl, ETHMemoImpl {
  EthereumTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required this.validator});

  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_EthTransactionImpl");
  final LiveTransactionForm<EthereumTransactionForm> validator;
  IntegerBalance? _remindTokenAmount;
  late final IntegerBalance _remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  late (BalanceCore, Token) remindAmount;
  bool _trReady = false;
  bool get trIsReady => _trReady;
  String? _error;
  String? get error => _error ?? estimateError;

  bool _checkTransaction() {
    _error = validator.validator.validateError();
    final transactionValue = validator.validator.callValue +
        (currentEIP1559Fee?.fee.balance ?? BigInt.zero);
    _remindAmount.updateBalance(
        account.address.address.currencyBalance - transactionValue);
    if (validator.validator.mode != ETHTransactionMode.erc20Transfer) {
      remindAmount = (_remindAmount, network.coinParam.token);
    } else {
      final tokenTransferFiled = validator.validator as EthereumTransferForm;
      final remindTokenAmounts =
          tokenTransferFiled.erc20Token!.balance.value.balance -
              tokenTransferFiled.tokenValue;
      _remindTokenAmount!.updateBalance(remindTokenAmounts);
      if (_remindAmount.isNegative ||
          validator.validator.mode != ETHTransactionMode.erc20Transfer) {
        remindAmount = (_remindAmount, network.coinParam.token);
      } else {
        remindAmount = (_remindTokenAmount!, tokenTransferFiled.token);
      }
    }
    final ready = _error == null &&
        !_remindAmount.isNegative &&
        !(_remindTokenAmount?.isNegative ?? false) &&
        gasInited &&
        (feeSpeed == EIP1559FeeSpeed.customFee || !updatingGas);

    return ready;
  }

  @override
  Future<void> onTapMemo(OnAddETHMemo onAddMemo) async {
    final String? currentMemo = memo;
    await super.onTapMemo(onAddMemo);
    if (memo != currentMemo) {
      estimateGasLimit();
    }
  }

  @override
  Future<void> estimateGasLimit({Map<String, dynamic>? estimateDetails}) async {
    final estimateDetails = validator.validator
        .toEstimate(address: address, network: network, memo: memo);
    await super.estimateGasLimit(estimateDetails: estimateDetails);
    notify();
  }

  void sedTransaction() async {
    try {
      final fee = currentEIP1559Fee?.clone();
      if (fee == null || !trIsReady) return;
      final transaction = validator.validator.toTransaction(
          address: address, network: network, fee: fee, memo: memo);
      progressKey.progressText("create_send_transaction"
          .tr
          .replaceOne(network.coinParam.token.name));
      final result = await MethodUtils.call(
          () async => await signAndBroadCastTransaction(transaction));
      if (result.hasError) {
        progressKey.errorText(result.error!.tr,
            showBackButton: true, backToIdle: false);
      } else {
        stopGasEstimate();
        progressKey.success(
            progressWidget: SuccessTransactionTextView(
              network: network,
              txId: [result.result],
            ),
            backToIdle: false);
      }
    } finally {
      notify();
    }
  }

  @override
  void onFeeChanged() {
    _trReady = _checkTransaction();
    notify();
  }

  void _onFormListener() => onFeeChanged();

  void _onEstimateNeeded() {
    estimateGasLimit();
  }

  /// 0x32Acb58B4F478372FEDB3ad52bC8a048Cbb3575A
  /// 0xe302bE89e4ab134bc9C82Bb413773bbD79c31bAC
  void _init() {
    if (validator.validator.mode == ETHTransactionMode.erc20Transfer) {
      final tokenTransferFiled = validator.validator as EthereumTransferForm;
      _remindTokenAmount =
          IntegerBalance.zero(tokenTransferFiled.token.decimal!);
    }
    _trReady = _checkTransaction();
  }

  @override
  void init() {
    super.init();

    validator.addListener(_onFormListener);
    validator.validator.onStimateChanged = _onEstimateNeeded;
  }

  @override
  void ready() {
    super.ready();
    startGasListening();
    _init();
    estimateGasLimit();
  }

  void _close() {
    validator.removeListener(onFeeChanged);
    validator.dispose();
    validator.validator.onStimateChanged = null;
  }

  @override
  void close() {
    super.close();
    _close();
  }
}
