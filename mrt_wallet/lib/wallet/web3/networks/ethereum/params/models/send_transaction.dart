import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/account.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthreumTransactionAccessList with CborSerializable {
  final ETHAddress address;
  final List<List<int>> storageKeys;
  Web3EthreumTransactionAccessList(
      {required this.address, required List<List<int>> storageKeys})
      : storageKeys = storageKeys.map((e) => e.asImmutableBytes).toImutableList;
  factory Web3EthreumTransactionAccessList.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.web3EthereumTransactionAccessList);
    return Web3EthreumTransactionAccessList(
        address: ETHAddress(values.elementAs(0)),
        storageKeys: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          address.address,
          CborListValue.fixedLength(
              storageKeys.map((e) => CborBytesValue(e)).toList())
        ]),
        CborTagsConst.web3EthereumTransactionAccessList);
  }
}

class Web3EthreumSendTransaction extends Web3EthereumRequestParam<String> {
  @override
  final Web3EthereumChainAccount account;
  final List<Web3EthreumTransactionAccessList>? accessList;
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

  Web3EthreumSendTransaction._(
      {required this.account,
      required this.to,
      List<Web3EthreumTransactionAccessList>? accessList,
      this.gas,
      this.gasPrice,
      required this.value,
      required List<int> data,
      this.maxFeePerGas,
      this.maxPriorityFeePerGas,
      this.chainId,
      this.transactionType})
      : accessList = accessList?.immutable,
        data = data.asImmutableBytes;

  factory Web3EthreumSendTransaction(
      {required Web3EthereumChainAccount account,
      required ETHAddress? to,
      required BigInt value,
      required int? gas,
      required List<int>? data,
      required BigInt? chainId,
      required BigInt? gasPrice,
      required BigInt? maxPriorityFeePerGas,
      required BigInt? maxFeePerGas,
      List<Web3EthreumTransactionAccessList>? accessList,
      int? transactionType}) {
    if (accessList?.isEmpty ?? false) {
      accessList = null;
    }
    if (gasPrice != null &&
        (maxFeePerGas != null || maxPriorityFeePerGas != null)) {
      throw Web3EthereumExceptionConst.invalidGasArg;
    }

    if ((maxFeePerGas != null && maxPriorityFeePerGas == null) ||
        (maxFeePerGas == null && maxPriorityFeePerGas != null)) {
      throw Web3EthereumExceptionConst.invalidEIP1559GasArg;
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
      if (accessList != null) {
        if (ethTransactionType == ETHTransactionType.legacy) {
          throw Web3RequestExceptionConst.invalidParameters(
              Web3RequestExceptionConst.invalidTransactionAccessList);
        }
      }
    } else {
      if (maxFeePerGas != null) {
        ethTransactionType = ETHTransactionType.eip1559;
      } else if (accessList != null) {
        ethTransactionType = ETHTransactionType.eip2930;
      } else if (gasPrice != null) {
        ethTransactionType = ETHTransactionType.legacy;
      }
    }
    return Web3EthreumSendTransaction._(
        account: account,
        to: to,
        value: value,
        gas: gas,
        gasPrice: gasPrice,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        data: data ?? const [],
        chainId: chainId,
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
    return Web3EthreumSendTransaction._(
        account: Web3EthereumChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
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
          account.toCbor(),
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
  Web3EthereumRequest<String, Web3EthreumSendTransaction> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final EthereumChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3EthereumRequest<String, Web3EthreumSendTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
