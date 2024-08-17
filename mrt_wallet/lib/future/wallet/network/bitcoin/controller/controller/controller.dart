import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';

typedef OnCustomOrdering
    = Future<(List<UtxoWithAddress>, List<BitcoinBaseOutput>)?> Function(
        List<UtxoWithAddress>, List<BitcoinBaseOutput>);

class BitcoinStateController extends BitcoinTransactionImpl
    with BitcoinTransactionFeeImpl {
  BitcoinStateController(
      {required super.chainAccount, required super.walletProvider});

  bool _trReady = false;
  bool get trReady => _trReady;

  @override
  void onSetupUtxo() {
    final sum = selectedUtxo.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    sumOfSelectedUtxo.updateBalance(sum);
    if (sum <= BigInt.zero) return;
    buildInputs();
    onCalculateAmount();
    calculateFee();
  }

  @override
  void onCalculateAmount() {
    final totalAmounts = receivers.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    setupAmount.updateBalance(totalAmounts);
    final remind =
        sumOfSelectedUtxo.balance - totalAmounts - transactionFee.balance;
    remindAmount.updateBalance(remind);
    buildOutputs();
    _trReady = _isReady();
  }

  //// checked

  bool _isReady() {
    final zeroOutput = receivers.any((element) => !element.hasAmount);
    return receivers.isNotEmpty &&
        !zeroOutput &&
        !remindAmount.isNegative &&
        !setupAmount.isZero;
  }

  @override
  void sendTransaction() {
    if (!trReady) return;
    super.sendTransaction();
  }
}
