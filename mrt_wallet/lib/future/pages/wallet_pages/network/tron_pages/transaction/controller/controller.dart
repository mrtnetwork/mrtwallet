import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/controller/impl/network_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';
import 'package:on_chain/tron/src/models/contract/base_contract/transaction_type.dart';

import 'impl/signer_impl.dart';

class TronTransactionStateController extends TronTransactionImpl
    with
        TronMemoImpl,
        NetworkConditionImpl,
        TronTransactionFeeIMpl,
        TronSignerImpl {
  TronTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.network,
      required super.apiProvider,
      required super.address,
      required this.validator});
  final LiveTransactionValidator<TronTransactionValidator> validator;
  String? _error;

  String? get error => _error;
  bool _trIsReady = false;
  bool get trIsReady => _trIsReady;

  NoneDecimalBalance? _remindTokenAmount;
  late final NoneDecimalBalance _remindAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  late (BalanceCore, Token) remindAmount;

  bool _checkTransaction() {
    _error = validator.validator.validateError();
    final transactionValue = validator.validator.callValue;
    _remindAmount.updateBalance(account.address.address.balance.value.balance -
        (transactionValue + (totalBurn?.balance ?? BigInt.zero)));
    if (validator.validator.type !=
        TransactionContractType.triggerSmartContract) {
      remindAmount = (_remindAmount, network.coinParam.token);
    } else {
      final tokenTransferFiled = validator.validator as TronTransferValidator;
      final remindTokenAmounts =
          tokenTransferFiled.transferToken!.balance.value.balance -
              tokenTransferFiled.tokenValue;
      _remindTokenAmount!.updateBalance(remindTokenAmounts);
      if (_remindAmount.isNegative) {
        remindAmount = (_remindAmount, network.coinParam.token);
      } else {
        remindAmount = (_remindTokenAmount!, tokenTransferFiled.token);
      }
    }
    return _error == null &&
        !_remindAmount.isNegative &&
        !(_remindTokenAmount?.isNegative ?? false) &&
        consumedFee != null;
  }

  @override
  Future<void> onTapMemo(OnAddTronMemo onAddMemo) async {
    final currentMemo = memo;
    await super.onTapMemo(onAddMemo);
    if (currentMemo != memo) {
      calculateFee();
    }
  }

  void _init() {
    if (validator.validator.type ==
        TransactionContractType.triggerSmartContract) {
      final tokenTransferFiled = validator.validator as TronTransferValidator;
      _remindTokenAmount =
          NoneDecimalBalance.zero(tokenTransferFiled.token.decimal!);
    }
    _trIsReady = _checkTransaction();
  }

  void sedTransaction() async {
    await signAndSendTransaction(validator.validator.toContract(owner: owner));
  }

  void _onValidatorListener() {
    _trIsReady = _checkTransaction();
    notify();
  }

  void _onEstimateNeeded() {
    calculateFee();
  }

  @override
  String get repositoryId => "tron/transaction";

  @override
  void ready() {
    super.ready();
    initNetworkCondition();
  }

  @override
  Future<bool> initNetworkCondition() async {
    final isOK = await super.initNetworkCondition();
    _init();
    _error = validator.validator.validateError();
    if (_error == null) {
      calculateFee();
    }
    return isOK;
  }

  @override
  void init() {
    super.init();
    _init();
    validator.addPageChangedListener(_onValidatorListener);
    validator.validator.onStimateChanged = _onEstimateNeeded;
  }

  @override
  void close() {
    validator.removePageChangedListener(_onValidatorListener);
    super.close();
  }

  @override
  TransactionContractType get type => validator.validator.type;

  @override
  TronTransactionValidator get field => validator.validator;

  @override
  void onFeeChanged() {
    _trIsReady = _checkTransaction();
    notify();
  }
}
