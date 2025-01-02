import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/messages/messages.dart';
import 'package:mrt_wallet/future/wallet/network/monero/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

mixin MoneroTransactionFeeImpl on MoneroTransactionImpl {
  DaemonGetEstimateFeeResponse? _fee;
  late final api = MoneroApi(client.provider);
  String? _feeError;
  String? get feeError => _feeError;
  MoneroFeePrority? _priority = MoneroFeePrority.defaultPriority;
  MoneroFeePrority? get priority => _priority;
  late Map<String, IntegerBalance> _fees;
  Map<String, IntegerBalance> get fees => _fees;

  @override
  DaemonGetEstimateFeeResponse get baseFee => _fee!;

  Map<String, IntegerBalance> _buildFeeRate(BigInt txWeight) {
    return {
      for (final i in MoneroFeePrority.values)
        i.name: IntegerBalance(
            i.calcuateFee(weight: txWeight, baseFee: baseFee),
            network.coinParam.decimal,
            imutable: true,
            allowNegative: false)
    };
  }

  Future<void> initialFee() async {
    _fee ??= await client.getFeeEstimate();
    fee.updateBalance(_fee?.fees[0]);
  }

  @override
  Future<void> calculateFee() async {
    final destinations = receivers.map((e) => e.toMoneroDestination()).toList();
    final fakePayments = selectedUtxos.values
        .expand((e) => e)
        .map((e) => e.toUnlockedFakePayment())
        .toList();
    final txWeight = await MethodUtils.call(() => walletProvider.wallet
        .nonEncryptedRequest(NoneEncryptedRequestFakeMoneroTx(
            destinations: destinations,
            fee: fee.balance,
            change: MoneroTxDestination(
                amount: remindAmount.balance, address: change.networkAddress),
            fakePayments: fakePayments)));
    _fees = _buildFeeRate(txWeight.result);
    if (_priority != null) {
      fee.updateBalance(_fees[priority?.name]?.balance);
    }
    onCalculateAmount();
    notify();
  }

  void setFee(String? feeType, {BigInt? customFee}) {
    if (feeType == null && customFee == null) return;
    _priority = feeType == null
        ? null
        : MoneroFeePrority.values
            .firstWhere((element) => element.name == feeType);
    if (_priority == null) {
      fee.updateBalance(customFee!);
    } else {
      fee.updateBalance(_fees[priority?.name]?.balance);
    }
    onCalculateAmount();
    notify();
  }
}
