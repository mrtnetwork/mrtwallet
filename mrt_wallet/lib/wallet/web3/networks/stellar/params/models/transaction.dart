import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarSendTransaction extends Web3StellarRequestParam<String> {
  final Envelope transaction;
  Web3StellarSendTransaction._({
    required this.account,
    required this.transaction,
    required this.method,
  });
  factory Web3StellarSendTransaction({
    required StellarAddress account,
    required Envelope transaction,
    required Web3StellarRequestMethods method,
  }) {
    switch (method) {
      case Web3StellarRequestMethods.sendTransaction:
      case Web3StellarRequestMethods.signTransaction:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3StellarSendTransaction._(
        account: account, transaction: transaction, method: method);
  }

  factory Web3StellarSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3StellarSendTransaction(
        account: StellarAddress.fromBase32Addr(values.elementAt(1)),
        transaction: Envelope.fromXdr(values.elementAt(2)),
        method: Web3StellarRequestMethods.fromId(
            values.elementAt<List<int>>(0).last));
  }

  @override
  final Web3StellarRequestMethods method;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.toString(),
          CborBytesValue(transaction.toVariantXDR()),
        ]),
        type.tag);
  }

  @override
  Map<String, String?> toJson() {
    return {};
  }

  @override
  Web3StellarRequest<String, Web3StellarSendTransaction> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required StellarChain chain}) {
    return Web3StellarRequest<String, Web3StellarSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  @override
  final StellarAddress account;
}
