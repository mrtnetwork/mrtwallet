import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/permission/models/account.dart';

class Web3StellarSendTransactionResponse {
  final String envlope;
  final String? txHash;
  const Web3StellarSendTransactionResponse(
      {required this.envlope, this.txHash});
  Map<String, dynamic> toJson() {
    return {"envlope": envlope, "tx_hash": txHash};
  }

  factory Web3StellarSendTransactionResponse.fromJson(
      Map<String, dynamic> json) {
    return Web3StellarSendTransactionResponse(
        envlope: json["envlope"], txHash: json["tx_hash"]);
  }
}

class Web3StellarSendTransaction
    extends Web3StellarRequestParam<Web3StellarSendTransactionResponse> {
  final List<int> transaction;
  Web3StellarSendTransaction._({
    required this.account,
    required List<int> transaction,
    required this.method,
  }) : transaction = transaction.asImmutableBytes;
  factory Web3StellarSendTransaction({
    required Web3StellarChainAccount account,
    required List<int> transaction,
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
        account: Web3StellarChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        transaction: values.elementAt(2),
        method: Web3StellarRequestMethods.fromId(
            values.elementAt<List<int>>(0).last));
  }

  @override
  final Web3StellarRequestMethods method;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [method.tag, account.toCbor(), CborBytesValue(transaction)]),
        type.tag);
  }

  @override
  Web3StellarRequest<Web3StellarSendTransactionResponse,
          Web3StellarSendTransaction>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final StellarChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3StellarRequest<Web3StellarSendTransactionResponse,
            Web3StellarSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  @override
  Object? toJsWalletResponse(Web3StellarSendTransactionResponse response) {
    return response.toJson();
  }

  @override
  final Web3StellarChainAccount account;
}
