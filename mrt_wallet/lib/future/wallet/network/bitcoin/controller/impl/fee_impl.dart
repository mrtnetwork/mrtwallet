import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

mixin BitcoinTransactionFeeImpl on BitcoinTransactionImpl {
  int? _trSize;
  BitcoinFeeRateType? _feeRateType = BitcoinFeeRateType.medium;
  BitcoinFeeRate? _networkFeeRate;
  BitcoinFeeRate get feeRate => _networkFeeRate!;
  @override
  bool get hasFeeRate => _networkFeeRate != null;
  late final IntegerBalance _feeRate =
      IntegerBalance.zero(network.coinParam.decimal);
  @override
  IntegerBalance get transactionFee => _feeRate;
  BitcoinFeeRateType? get feeRateType => _feeRateType;

  late Map<String, IntegerBalance> _fees;
  Map<String, IntegerBalance> get fees => _fees;
  String? _feeError;

  String? get feeError => _feeError;

  Map<String, IntegerBalance> _buildFeeRate() {
    return {
      BitcoinFeeRateType.medium.name: IntegerBalance(
          feeRate.getEstimate(_trSize!, feeRateType: BitcoinFeeRateType.medium),
          network.coinParam.decimal),
      BitcoinFeeRateType.low.name: IntegerBalance(
          feeRate.getEstimate(_trSize!, feeRateType: BitcoinFeeRateType.low),
          network.coinParam.decimal),
      BitcoinFeeRateType.high.name: IntegerBalance(
          feeRate.getEstimate(_trSize!, feeRateType: BitcoinFeeRateType.high),
          network.coinParam.decimal),
    };
  }

  @override
  void setFee(String? feeType, {BigInt? customFee}) {
    if (feeType == null && customFee == null) return;
    _feeRateType = feeType == null
        ? null
        : BitcoinFeeRateType.values
            .firstWhere((element) => element.name == feeType);
    if (_feeRateType == null) {
      _feeRate.updateBalance(customFee!);
    } else {
      _feeRate.updateBalance(
          _networkFeeRate!.getEstimate(_trSize!, feeRateType: _feeRateType!));
    }
    _checkFeeAlert();
    super.setFee(feeType, customFee: customFee);
  }

  Future<BitcoinFeeRate> _getFeeRate() async {
    return apiProvider.getFeeRate();
  }

  Future<(int, BitcoinFeeRate)> _getTransactionSize({
    required List<UtxoWithAddress> utxos,
    required List<BitcoinBaseOutput> outPuts,
  }) async {
    int transactionSize;
    if (isBCHTransaction) {
      transactionSize = ForkedTransactionBuilder.estimateTransactionSize(
          utxos: utxos,
          enableRBF: true,
          outputs: outPuts,
          network: network.coinParam.transacationNetwork as BitcoinCashNetwork);
    } else {
      transactionSize = BitcoinTransactionBuilder.estimateTransactionSize(
          utxos: utxos,
          enableRBF: true,
          outputs: outPuts,
          network: network.coinParam.transacationNetwork);
    }
    BitcoinFeeRate? networkFee = _networkFeeRate;
    networkFee ??= await _getFeeRate();
    return (transactionSize, networkFee);
  }

  @override
  Future<void> estimateFee({
    required List<BitcoinBaseOutput> outPuts,
    required List<UtxoWithAddress> inputs,
    BCMR? bcmr,
  }) async {
    final result = await _getTransactionSize(outPuts: outPuts, utxos: inputs);
    _trSize = result.$1;
    _networkFeeRate ??= result.$2;
    if (_feeRateType != null) {
      _feeRate.updateBalance(
          _networkFeeRate!.getEstimate(_trSize!, feeRateType: _feeRateType!));
    }

    _fees = _buildFeeRate();
    _checkFeeAlert();
  }

  void _checkFeeAlert() {
    _feeError = null;
    if (_feeRateType == null) {
      if (_feeRate.balance < _fees[BitcoinFeeRateType.low.name]!.balance) {
        _feeError = "transaction_fee_warning";
      }
    }
  }
}
