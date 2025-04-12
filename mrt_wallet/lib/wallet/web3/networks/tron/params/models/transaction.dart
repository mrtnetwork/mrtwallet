import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/models/account.dart';

class Web3TronSendTransaction extends Web3TronRequestParam<String> {
  final List<int> transaction;
  final String? txId;
  @override
  final Web3TronChainAccount account;

  Web3TronSendTransaction(
      {required List<int> transaction, this.txId, required this.account})
      : transaction = transaction.asImmutableBytes;

  factory Web3TronSendTransaction.deserialize({
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
    return Web3TronSendTransaction(
        transaction: values.elementAt(1),
        txId: values.elementAt(2),
        account: Web3TronChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(3)));
  }

  @override
  Web3TronRequestMethods get method => Web3TronRequestMethods.signTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [method.tag, CborBytesValue(transaction), txId, account.toCbor()]),
        type.tag);
  }

  @override
  Web3TronRequest<String, Web3TronSendTransaction> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final TronChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3TronRequest<String, Web3TronSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
