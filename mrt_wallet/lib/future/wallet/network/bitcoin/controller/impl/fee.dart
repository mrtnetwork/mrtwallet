import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/utils/utils.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

enum BitcoinTxFee {
  low,
  medium,
  high,
  custom;

  BitcoinFeeRateType? get type {
    switch (this) {
      case low:
        return BitcoinFeeRateType.low;
      case high:
        return BitcoinFeeRateType.high;
      case medium:
        return BitcoinFeeRateType.medium;
      default:
        return null;
    }
  }

  static BitcoinTxFee fromName(String? name) {
    if (name == null) return BitcoinTxFee.custom;
    return values.firstWhere((e) => e.name == name);
  }
}

class BitcoinTxSize {
  final int size;
  final bool segwit;
  final String? desc;
  const BitcoinTxSize._(
      {required this.size, required this.segwit, required this.desc});
  factory BitcoinTxSize(
      {required int size,
      required bool segwit,
      required IntegerBalance feeRate}) {
    return BitcoinTxSize._(
        size: size,
        segwit: segwit,
        desc: () {
          if (!feeRate.largerThanZero) return null;
          final f = feeRate.balance ~/ BigInt.from(size);
          if (segwit) {
            return "${f}sat/vB";
          }
          return "${f}sat/B";
        }());
  }
  BitcoinTxSize copyWith(
      {required IntegerBalance feeRate, int? size, bool? segwit}) {
    return BitcoinTxSize(
        size: size ?? this.size,
        segwit: segwit ?? this.segwit,
        feeRate: feeRate);
  }
}

typedef ONCHANGEFEE = Future<(String?, BigInt?)?> Function(
    Map<String, IntegerBalance> fees, String? type, BigInt? fee);
mixin BitcoinTransactionFeeController {
  BitcoinClient get client;
  WalletBitcoinNetwork get network;
  BitcoinTxFee _feeRateType = BitcoinTxFee.medium;
  BitcoinTxFee get feeRateType => _feeRateType;
  BitcoinFeeRate? _networkFeeRate;
  String? get feePerByte => _txSize?.desc;
  Map<String, IntegerBalance>? _fees;
  Map<String, IntegerBalance>? get fees => _fees;
  bool get hasNetworkFee => _networkFeeRate != null;
  BitcoinTxSize? _txSize;
  final IntegerBalance fee =
      IntegerBalance.zero(BTCUtils.decimal, allowNegative: false);

  static Map<String, IntegerBalance> _buildNetworkFees(
      {required BitcoinFeeRate feeRate, required int size}) {
    return {
      BitcoinTxFee.medium.name: IntegerBalance(
          feeRate.getEstimate(size, feeRateType: BitcoinFeeRateType.medium),
          BTCUtils.decimal),
      BitcoinTxFee.low.name: IntegerBalance(
          feeRate.getEstimate(size, feeRateType: BitcoinFeeRateType.low),
          BTCUtils.decimal),
      BitcoinTxFee.high.name: IntegerBalance(
          feeRate.getEstimate(size, feeRateType: BitcoinFeeRateType.high),
          BTCUtils.decimal)
    };
  }

  Future<void> initNetworkFee() async {
    final fee = await MethodUtils.call(() async {
      final fee = await client.getFeeRate();
      if (fee == null) {
        return BitcoinFeeRate(
            high: BigInt.from(1024 * 3),
            medium: BigInt.from(1024 * 2),
            low: BigInt.from(1024));
      }
      return fee;
    });
    if (fee.hasResult) {
      _networkFeeRate = fee.result;
      return;
    }
    _feeRateType = BitcoinTxFee.custom;
  }

  Future<void> changeFee(ONCHANGEFEE onTap) async {
    final fee =
        await onTap(_fees ?? {}, feeRateType.type?.name, this.fee.balance);
    if (fee == null) return;
    final String? feeName = fee.$1;
    final BigInt? customFee = fee.$2;
    final feeType = BitcoinTxFee.fromName(feeName);
    if (feeType != BitcoinTxFee.custom && _fees == null) return;
    if (feeType == BitcoinTxFee.custom && customFee == null) return;
    _feeRateType = feeType;
    if (feeType == BitcoinTxFee.custom) {
      this.fee.updateBalance(customFee!);
    } else {
      this.fee.updateBalance(_networkFeeRate!
          .getEstimate(_txSize!.size, feeRateType: feeType.type!));
    }
    _txSize = _txSize?.copyWith(feeRate: this.fee);
  }

  BitcoinTxSize _getTransactionSize(
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
    return BitcoinTxSize(
        size: transactionSize,
        segwit: utxos.any((e) => e.utxo.isSegwit),
        feeRate: fee);
  }

  void estimateFee(
      {required List<BitcoinBaseOutput> outPuts,
      required List<UtxoWithAddress> inputs,
      BCMR? bcmr}) {
    final size = MethodUtils.nullOnException(
        () => _getTransactionSize(utxos: inputs, outPuts: outPuts));
    if (size == null || _networkFeeRate == null) return;
    _fees = _buildNetworkFees(feeRate: _networkFeeRate!, size: size.size);
    final type = _feeRateType.type;
    if (type != null) {
      fee.updateBalance(
          _networkFeeRate!.getEstimate(size.size, feeRateType: type));
    }
    _txSize = size.copyWith(feeRate: fee);
  }
}
