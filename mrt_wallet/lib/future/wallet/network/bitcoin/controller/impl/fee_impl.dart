import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

mixin BitcoinTransactionFeeImpl {
  BitcoinClient get client;
  WalletBitcoinNetwork get network;
  int? _trSize;
  int get transactionSize => _trSize ?? 0;
  bool get hasSegwit;
  BitcoinFeeRateType? _feeRateType = BitcoinFeeRateType.medium;
  BitcoinFeeRate? _networkFeeRate;
  BitcoinFeeRate? get feeRate => _networkFeeRate;
  String? _feePerByteDesc;
  String? get feePerByteDesc => _feePerByteDesc;
  bool get hasFeeRate => _networkFeeRate != null;
  late final IntegerBalance _feeRate =
      IntegerBalance.zero(network.coinParam.decimal);
  IntegerBalance get transactionFee => _feeRate;
  BitcoinFeeRateType? get feeRateType => _feeRateType;

  late Map<String, IntegerBalance> _fees;
  Map<String, IntegerBalance> get fees => _fees;
  String? _feeError;
  String? get feeError => _feeError;
  bool get hasFee => _feeRate.largerThanZero;
  bool get isFeeValid => hasFee && _feeError == null;

  Map<String, IntegerBalance> _buildFeeRate() {
    if (feeRate == null || _trSize == null) return {};
    return {
      BitcoinFeeRateType.medium.name: IntegerBalance(
          feeRate!
              .getEstimate(_trSize!, feeRateType: BitcoinFeeRateType.medium),
          network.coinParam.decimal),
      BitcoinFeeRateType.low.name: IntegerBalance(
          feeRate!.getEstimate(_trSize!, feeRateType: BitcoinFeeRateType.low),
          network.coinParam.decimal),
      BitcoinFeeRateType.high.name: IntegerBalance(
          feeRate!.getEstimate(_trSize!, feeRateType: BitcoinFeeRateType.high),
          network.coinParam.decimal),
    };
  }

  void changeFee(String? feeType, {BigInt? customFee}) {
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
    // super.setFee(feeType, customFee: customFee);
  }

  Future<BitcoinFeeRate?> _getFeeRate() async {
    return client.getFeeRate();
  }

  int _getTransactionSize(
      {required List<UtxoWithAddress> utxos,
      required List<BitcoinBaseOutput> outPuts}) {
    int transactionSize;
    if (network.coinParam.isForked) {
      transactionSize = ForkedTransactionBuilder.estimateTransactionSize(
          utxos: utxos,
          enableRBF: true,
          outputs: outPuts,
          network: network.coinParam.transacationNetwork);
    } else {
      transactionSize = BitcoinTransactionBuilder.estimateTransactionSize(
          utxos: utxos,
          enableRBF: true,
          outputs: outPuts,
          network: network.coinParam.transacationNetwork);
    }
    return transactionSize;
  }

  Future<void> estimateFee(
      {required List<BitcoinBaseOutput> outPuts,
      required List<UtxoWithAddress> inputs,
      BCMR? bcmr}) async {
    _trSize = MethodUtils.nullOnException(
        () => _getTransactionSize(utxos: inputs, outPuts: outPuts));
    assert(_trSize != null, "should never failed to get transaction size.");
    if (_networkFeeRate == null) {
      final result = await MethodUtils.call(() async {
        return _getFeeRate();
      });
      if (result.hasResult) {
        _networkFeeRate = result.result;
      }
    }
    if (_feeRateType != null && _networkFeeRate != null && _trSize != null) {
      _feeRate.updateBalance(
          _networkFeeRate!.getEstimate(_trSize!, feeRateType: _feeRateType!));
    }

    _fees = _buildFeeRate();
    _checkFeeAlert();
  }

  void _checkFeeAlert() {
    _feeError = null;
    _feePerByteDesc =
        _calcFeePerByte(feeRate: _feeRate, size: _trSize, hasSegwit: hasSegwit);
    if (!hasFee) {
      _feeError = "setup_fee_manually";
    }
    if (_feeRateType == null && _networkFeeRate != null) {
      if (_feeRate.balance < _fees[BitcoinFeeRateType.low.name]!.balance) {
        _feeError = "transaction_fee_warning";
      }
    }
  }

  static String? _calcFeePerByte({
    required int? size,
    required IntegerBalance feeRate,
    required bool hasSegwit,
  }) {
    if (size == null || !feeRate.largerThanZero) return null;
    final f = feeRate.balance ~/ BigInt.from(size);
    if (hasSegwit) {
      return "${f}sat/vB";
    }
    return "${f}sat/B";
  }
}
