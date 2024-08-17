import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthreumSendTransaction extends Web3EthereumRequestParam<String> {
  final ETHAddress from;
  final ETHAddress? to;
  final int? gas;
  final BigInt? chainId;
  final BigInt? gasPrice;
  final BigInt? maxFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  final BigInt value;
  final List<int> data;
  final ETHTransactionType? transactionType;

  bool get isEip1559Metrics => maxFeePerGas != null;
  bool get isLegacyFeeMetrics => gasPrice != null;
  bool get hasFee => isEip1559Metrics || isLegacyFeeMetrics || gas != null;

  Web3EthreumSendTransaction(
      {required this.from,
      required this.to,
      this.gas,
      this.gasPrice,
      required this.value,
      required this.data,
      this.maxFeePerGas,
      this.maxPriorityFeePerGas,
      this.chainId,
      this.transactionType});

  factory Web3EthreumSendTransaction.fromJson(Map<String, dynamic> json) {
    const method = Web3EthereumRequestMethods.sendTransaction;
    final BigInt? gasPrice = Web3ValidatorUtils.parseBigInt<BigInt?>(
        key: "gasPrice", method: method, json: json);
    final BigInt? maxPriorityFeePerGas =
        Web3ValidatorUtils.parseBigInt<BigInt?>(
            key: "maxPriorityFeePerGas", method: method, json: json);
    final BigInt? maxFeePerGas = Web3ValidatorUtils.parseBigInt<BigInt?>(
        key: "maxFeePerGas", method: method, json: json);
    final transactionType = Web3ValidatorUtils.parseInt<int?>(
        key: "type", method: method, json: json);

    if (gasPrice != null &&
        (maxFeePerGas != null || maxPriorityFeePerGas != null)) {
      throw Web3RequestExceptionConst.ethGasArgrument;
    }

    if ((maxFeePerGas != null && maxPriorityFeePerGas == null) ||
        (maxFeePerGas == null && maxPriorityFeePerGas != null)) {
      throw Web3RequestExceptionConst.ethGasArgrument2;
    }

    ETHTransactionType? ethTransactionType = ETHTransactionType.values
        .firstWhereOrNull((e) => e.prefix == transactionType);
    if (transactionType != null && ethTransactionType == null) {
      throw Web3RequestExceptionConst.invalidParameters(
          Web3RequestExceptionConst.invalidTransactionTypeMessage);
    }
    if (ethTransactionType != null) {
      if (maxFeePerGas != null) {
        if (ethTransactionType != ETHTransactionType.eip1559) {
          throw Web3RequestExceptionConst.invalidParameters(
              Web3RequestExceptionConst.invalidTransactionTypeOrGas);
        }
      }
      if (gasPrice != null) {
        if (ethTransactionType == ETHTransactionType.eip1559) {
          throw Web3RequestExceptionConst.invalidParameters(
              Web3RequestExceptionConst.invalidTransactionTypeOrGas);
        }
      }
    } else {
      if (maxFeePerGas != null) {
        ethTransactionType = ETHTransactionType.eip1559;
      } else if (gasPrice != null) {
        ethTransactionType = ETHTransactionType.legacy;
      }
    }

    return Web3EthreumSendTransaction(
        from: Web3ValidatorUtils.parseAddress<ETHAddress>(
            onParse: (c) => ETHAddress(c),
            key: "from",
            method: method,
            json: json),
        to: Web3ValidatorUtils.parseAddress<ETHAddress?>(
            onParse: (c) => ETHAddress(c),
            key: "to",
            method: method,
            json: json),
        value: Web3ValidatorUtils.parseBigInt<BigInt>(
            key: "value", method: method, json: json),
        gas: Web3ValidatorUtils.parseInt<int?>(
            key: "gas", method: method, json: json),
        gasPrice: gasPrice,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        data: Web3ValidatorUtils.parseHex<List<int>?>(
                key: "data", method: method, json: json) ??
            const [],
        chainId: Web3ValidatorUtils.parseBigInt<BigInt?>(
            key: "chainId", method: method, json: json),
        transactionType: ethTransactionType);
  }

  factory Web3EthreumSendTransaction.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final String? to = values.elementAt(2);
    final int? trType = values.elementAt(10);
    return Web3EthreumSendTransaction(
        from: ETHAddress(values.elementAt(1)),
        to: to == null ? null : ETHAddress(to),
        gas: values.elementAt(3),
        gasPrice: values.elementAt(4),
        maxFeePerGas: values.elementAt(5),
        maxPriorityFeePerGas: values.elementAt(6),
        value: values.elementAt(7),
        data: values.elementAt(8),
        chainId: values.elementAt(9),
        transactionType:
            trType == null ? null : ETHTransactionType.fromPrefix(trType));
  }

  @override
  Web3EthereumRequestMethods get method =>
      Web3EthereumRequestMethods.sendTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          from.address,
          to?.address,
          gas,
          gasPrice,
          maxFeePerGas,
          maxPriorityFeePerGas,
          value,
          CborBytesValue(data),
          chainId,
          transactionType?.prefix
        ]),
        type.tag);
  }

  @override
  Map<String, String?> toJson() {
    return {
      "from": from.address,
      "to": to?.address,
      "gas": gas?.toRadix16,
      "gasPrice": gasPrice?.toRadix16,
      "maxFeePerGas": maxFeePerGas?.toRadix16,
      "maxPriorityFeePerGas": maxPriorityFeePerGas?.toRadix16,
      "value": value.toRadix16,
      "data": BytesUtils.toHexString(data, prefix: "0x"),
      "type": transactionType?.prefix.toRadix16
    };
  }

  @override
  ETHAddress? get account => from;

  @override
  Web3EthereumRequest<String, Web3EthreumSendTransaction> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required EthereumChain chain,
  }) {
    return Web3EthereumRequest<String, Web3EthreumSendTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
