import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronSendTransaction
    extends Web3TronRequestParam<Map<String, dynamic>> {
  final Transaction transaction;
  final String? txId;
  @override
  final TronAddress account;

  Web3TronSendTransaction(
      {required this.transaction, this.txId, TronAddress? account})
      : account = account ?? transaction.rawData.ownerAddress;

  factory Web3TronSendTransaction.fromJson(Map<String, dynamic> json,
      {TronAddress? account}) {
    Transaction transaction;
    try {
      transaction =
          Transaction.fromJson(StringUtils.toJson(json["transaction"]));
    } on TronPluginException catch (e) {
      throw Web3RequestExceptionConst.invalidParameters(e.message);
    } catch (e) {
      throw Web3TronExceptionConstant.invalidTransactionParams;
    }
    return Web3TronSendTransaction(
        transaction: transaction,
        account: account,
        txId: Web3ValidatorUtils.parseHex(
            key: "txId",
            method: Web3TronRequestMethods.signTransaction,
            json: json));
  }

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
        transaction: Transaction.deserialize(values.elementAt(1)),
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
          CborBytesValue(transaction.toBuffer()),
          txId,
          account.toAddress()
        ]),
        type.tag);
  }

  @override
  Map<String, String?> toJson() {
    return {
      "transaction": StringUtils.fromJson(transaction.toJson()),
    };
  }

  // @override
  // TronAddress? get account => ;

  @override
  Web3TronRequest<Map<String, dynamic>, Web3TronSendTransaction> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required TronChain chain}) {
    return Web3TronRequest<Map<String, dynamic>, Web3TronSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
