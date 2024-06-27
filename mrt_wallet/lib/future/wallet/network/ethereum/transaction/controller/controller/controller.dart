import 'dart:async';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/signer_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';

class EthereumTransactionStateController extends EthTransactionImpl
    with ETHTransactionFeeImpl, ETHSignerImpl, ETHMemoImpl {
  EthereumTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.network,
      required super.apiProvider,
      required super.address,
      required this.validator});
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
        account.address.address.balance.value.balance - transactionValue);
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

    return _error == null &&
        !_remindAmount.isNegative &&
        !(_remindTokenAmount?.isNegative ?? false) &&
        gasInited &&
        (feeSpeed == EIP1559FeeSpeed.customFee || !updatingGas);
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
      if (!trIsReady) return;
      final transaction = validator.validator.toTransaction(
          address: address,
          network: network,
          fee: currentEIP1559Fee?.clone(),
          memo: memo);
      await signAndSendTransaction(transaction);
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
    _init();
    super.init();

    validator.addListener(_onFormListener);
    validator.validator.onStimateChanged = _onEstimateNeeded;
  }

  @override
  void ready() {
    super.ready();
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

  @override
  String get repositoryId => "ethereum/transaction";
}
