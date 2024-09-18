import 'package:mrt_wallet/future/wallet/network/ton/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ton/transaction/controller/impl/signer_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ton/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';

class TonTransactionStateController extends TonTransactionImpl
    with TonSignerImpl, TonFeeImpl {
  TonTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.network,
      required super.address,
      required super.apiProvider,
      required super.validator});

  void _onReadyForm(String hashCode) {
    estimateFee();
  }

  bool get hasMultipleMessage => address.context.version.version > 1;

  late final IntegerBalance remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);

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
    final remind = address.address.currencyBalance - (totalAmounts + fee);
    remindAmount.updateBalance(remind);
    _trReady = _isReady();
    notify();
  }

  void _init() {
    validator.validator.onReadyField = _onReadyForm;
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
}
