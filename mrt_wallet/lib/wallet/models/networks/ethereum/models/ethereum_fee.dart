import 'package:mrt_wallet/crypto/utils/ethereum/utils.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';

class EthereumFee {
  EthereumFee._({
    required this.gasLimit,
    required this.fee,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
  });
  EthereumFee copyWith({
    int? gasLimit,
    IntegerBalance? fee,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) {
    return EthereumFee._(
      gasLimit: gasLimit ?? this.gasLimit,
      fee: fee ?? this.fee,
      gasPrice: gasPrice ?? this.gasPrice,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
    );
  }

  EthereumFee clone() {
    return EthereumFee._(
        gasLimit: gasLimit,
        fee: IntegerBalance(fee.balance, EthereumUtils.decimal),
        gasPrice: gasPrice,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxFeePerGas);
  }

  factory EthereumFee.legacy(int gasLimit, BigInt gasPrice) {
    final fee = gasPrice * BigInt.from(gasLimit);
    return EthereumFee._(
        gasLimit: gasLimit,
        gasPrice: gasPrice,
        fee: IntegerBalance(fee, EthereumUtils.decimal));
  }
  factory EthereumFee.eip1559(
      int gasLimit, BigInt maxPriorityFeePerGas, BigInt baseFee,
      {BigInt? maxFeePerGas}) {
    final mFeePerGas = maxFeePerGas ?? maxPriorityFeePerGas + baseFee;
    final fee = mFeePerGas * BigInt.from(gasLimit);
    return EthereumFee._(
        gasLimit: gasLimit,
        maxFeePerGas: mFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        fee: IntegerBalance(fee, EthereumUtils.decimal));
  }

  final int gasLimit;
  final BigInt? gasPrice;
  final BigInt? maxFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  final IntegerBalance fee;

  bool get isEIP1559 => maxFeePerGas != null;

  @override
  String toString() {
    return '''EthereumFee{
    gasLimit: $gasLimit,
    gasPrice: $gasPrice,
    maxFeePerGas: $maxFeePerGas,
    maxPriorityFeePerGas: $maxPriorityFeePerGas.
    fee: $fee
    }''';
  }
}
