import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronSendTransaction
    extends Web3TronRequestParam<Map<String, dynamic>> {
  final Map<String, dynamic> transaction;
  final String? txId;
  @override
  final TronAddress account;

  Web3TronSendTransaction(
      {required Map<String, dynamic> transaction,
      this.txId,
      required this.account})
      : transaction = transaction.immutable;

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
        transaction: StringUtils.toJson(values.elementAt(1)),
        txId: values.elementAt(2),
        account: TronAddress(values.elementAt(3)));
  }

  @override
  Web3TronRequestMethods get method => Web3TronRequestMethods.signTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          StringUtils.fromJson(transaction),
          txId,
          account.toAddress()
        ]),
        type.tag);
  }

  @override
  Map<String, String?> toJson() {
    return {
      "transaction": StringUtils.fromJson(transaction),
    };
  }

  @override
  Web3TronRequest<Map<String, dynamic>, Web3TronSendTransaction> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final TronChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3TronRequest<Map<String, dynamic>, Web3TronSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
