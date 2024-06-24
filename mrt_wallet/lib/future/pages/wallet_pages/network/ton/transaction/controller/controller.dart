import 'package:mrt_wallet/future/pages/wallet_pages/network/ton/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';

import 'impl/signer_impl.dart';
import 'impl/transaction_impl.dart';

class TonTransactionStateController extends TonTransactionImpl
    with TonSignerImpl, TonFeeImpl {
  TonTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.network,
      required super.address,
      required super.apiProvider,
      required super.validator});

  void _onReadyValidator(String hashCode) {
    estimateFee();
  }

  late final NoneDecimalBalance remindAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);

  String? _error;
  String? get error => _error;
  bool _trReady = false;
  bool get transactionIsReady => _trReady;

  bool _isReady() {
    _error = validator.validator.validateError();
    if (remindAmount.isNegative || _error != null) return false;
    if (hasFee) return true;
    return feeError != null;
  }

  @override
  void onChange() {
    final totalAmounts = validator.validator.callValue;
    final remind = address.address.balance.value.balance - (totalAmounts + fee);
    remindAmount.updateBalance(remind);
    _trReady = _isReady();
    notify();
  }

  void _init() {
    validator.validator.onReadyField = _onReadyValidator;
    validator.addListener(onChange);
  }

  void _close() {
    validator.validator.onReadyField = null;
    validator.removeListener(onChange);
  }

  void sendTransaction() {
    if (!transactionIsReady) return;
    signAndSendTransaction();
  }

  @override
  void ready() {
    super.ready();
    _init();
  }

  @override
  void close() {
    super.close();
    _close();
  }

  @override
  String get repositoryId => "ton/transaction";
}
