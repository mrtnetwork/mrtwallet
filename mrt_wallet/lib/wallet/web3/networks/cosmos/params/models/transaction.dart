import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/permission/models/account.dart';

abstract class Web3CosmosSignTransactionResponse {
  final Web3CosmosRequestMethods method;
  final List<int> signature;
  final Any publicKey;
  String singaureAsBase64() {
    return StringUtils.decode(signature, type: StringEncoding.base64);
  }

  Web3CosmosSignTransactionResponse._(
      {required this.method,
      required List<int> signature,
      required this.publicKey})
      : signature = signature.asImmutableBytes;
  Map<String, dynamic> toJson();
  factory Web3CosmosSignTransactionResponse.fromJson(
      Map<String, dynamic> json) {
    final method = Web3CosmosRequestMethods.fromName(json["method"]);
    return switch (method) {
      Web3CosmosRequestMethods.signTransactionDirect =>
        Web3CosmosSignTransactionDirectSignResponse.fromJson(json),
      Web3CosmosRequestMethods.signTransactionAmino =>
        Web3CosmosSignTransactionAminoSignResponse.fromJson(json),
      _ => throw Web3RequestExceptionConst.invalidRequest
    };
  }

  T cast<T extends Web3CosmosSignTransactionResponse>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as T;
  }
}

class Web3CosmosSignTransactionDirectSignResponse
    extends Web3CosmosSignTransactionResponse {
  final List<int> bodyBytes;
  final List<int> authInfoBytes;
  final String chainId;
  final BigInt accountNumber;

  Web3CosmosSignTransactionDirectSignResponse(
      {required List<int> bodyBytes,
      required List<int> authInfoBytes,
      required super.signature,
      required this.chainId,
      required this.accountNumber,
      required super.publicKey})
      : bodyBytes = bodyBytes.asImmutableBytes,
        authInfoBytes = authInfoBytes.asImmutableBytes,
        super._(method: Web3CosmosRequestMethods.signTransactionDirect);

  factory Web3CosmosSignTransactionDirectSignResponse.fromJson(
      Map<String, dynamic> json) {
    return Web3CosmosSignTransactionDirectSignResponse(
        bodyBytes: (json["bodyBytes"] as List).cast(),
        authInfoBytes: (json["authInfoBytes"] as List).cast(),
        signature: (json["signature"] as List).cast(),
        chainId: json["chainId"],
        accountNumber: BigintUtils.parse(json["accountNumber"]),
        publicKey: Any.fromJson(json["pubKey"]));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "method": method.name,
      "bodyBytes": bodyBytes,
      "authInfoBytes": authInfoBytes,
      "chainId": chainId,
      "accountNumber": accountNumber.toString(),
      "signature": signature,
      "pubKey": publicKey.toJson()
    };
  }
}

class Web3CosmosSignTransactionAminoSignResponse
    extends Web3CosmosSignTransactionResponse {
  final AminoTx tx;
  Web3CosmosSignTransactionAminoSignResponse({
    required super.signature,
    required this.tx,
    required super.publicKey,
  }) : super._(method: Web3CosmosRequestMethods.signTransactionAmino);
  factory Web3CosmosSignTransactionAminoSignResponse.fromJson(
      Map<String, dynamic> json) {
    return Web3CosmosSignTransactionAminoSignResponse(
        signature: (json["signature"] as List).cast(),
        tx: AminoTx.fromJson(json["tx"]),
        publicKey: Any.fromJson(json["pubKey"]));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "method": method.name,
      "tx": tx.toJson(),
      "signature": signature,
      "pubKey": publicKey.toJson()
    };
  }
}

abstract class Web3CosmosSignTransactionParams with CborSerializable {
  final Web3CosmosRequestMethods method;
  const Web3CosmosSignTransactionParams({required this.method});
  factory Web3CosmosSignTransactionParams.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: hex);
    final method = Web3CosmosRequestMethods.fromId(tag.tags.firstOrNull);
    return switch (method) {
      Web3CosmosRequestMethods.signTransactionAmino =>
        Web3CosmosSignTransactionAminoParams.deserialize(obj: tag),
      Web3CosmosRequestMethods.signTransactionDirect =>
        Web3CosmosSignTransactionDirectParams.deserialize(obj: tag),
      _ => throw Web3RequestExceptionConst.invalidRequest
    };
  }
}

class Web3CosmosSignTransactionDirectParams
    extends Web3CosmosSignTransactionParams {
  final List<int> bodyBytes;
  final List<int>? authInfos;
  final BigInt? accountNumber;
  Web3CosmosSignTransactionDirectParams({
    required List<int> bodyBytes,
    required List<int>? authInfos,
    required this.accountNumber,
  })  : bodyBytes = bodyBytes.asImmutableBytes,
        authInfos = authInfos?.asImmutableBytes,
        super(method: Web3CosmosRequestMethods.signTransactionDirect);
  factory Web3CosmosSignTransactionDirectParams.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: [Web3CosmosRequestMethods.signTransactionDirect.id]);
    return Web3CosmosSignTransactionDirectParams(
        bodyBytes: values.elementAs(0),
        authInfos: values.elementAs(1),
        accountNumber: values.elementAs(2));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(bodyBytes),
          authInfos == null ? const CborNullValue() : CborBytesValue(authInfos!)
        ]),
        [method.id]);
  }
}

class Web3CosmosSignTransactionAminoParams
    extends Web3CosmosSignTransactionParams {
  final AminoTx tx;
  Web3CosmosSignTransactionAminoParams(this.tx)
      : super(method: Web3CosmosRequestMethods.signTransactionAmino);
  factory Web3CosmosSignTransactionAminoParams.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: [Web3CosmosRequestMethods.signTransactionAmino.id]);
    final data =
        StringUtils.toJson(StringUtils.decode(values.elementAs<List<int>>(0)));
    return Web3CosmosSignTransactionAminoParams(AminoTx.fromJson(data));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([CborBytesValue(tx.toBuffer())]),
        [method.id]);
  }
}

class Web3CosmosSignTransaction
    extends Web3CosmosRequestParam<Web3CosmosSignTransactionResponse> {
  @override
  final Web3CosmosChainAccount account;
  final String chainId;
  final Web3CosmosSignTransactionParams transaction;
  final bool? preferNoSetFee;
  final bool? preferNoSetMemo;
  final bool? disableBalanceCheck;
  final BigInt? timeoutHeight;

  Web3CosmosSignTransaction._(
      {required this.account,
      required this.chainId,
      required this.transaction,
      required this.preferNoSetFee,
      required this.preferNoSetMemo,
      required this.disableBalanceCheck,
      required this.timeoutHeight});
  factory Web3CosmosSignTransaction({
    required Web3CosmosChainAccount account,
    required String chainId,
    required Web3CosmosSignTransactionParams transaction,
    bool? preferNoSetFee,
    bool? preferNoSetMemo,
    bool? disableBalanceCheck,
    BigInt? timeoutHeight,
  }) {
    switch (transaction.method) {
      case Web3CosmosRequestMethods.signTransactionAmino:
      case Web3CosmosRequestMethods.signTransactionDirect:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3CosmosSignTransaction._(
        account: account,
        chainId: chainId,
        disableBalanceCheck: disableBalanceCheck,
        preferNoSetFee: preferNoSetFee,
        preferNoSetMemo: preferNoSetMemo,
        transaction: transaction,
        timeoutHeight: timeoutHeight);
  }

  factory Web3CosmosSignTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3CosmosSignTransaction(
        account: Web3CosmosChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        chainId: values.elementAs(2),
        transaction: Web3CosmosSignTransactionParams.deserialize(
            obj: values.getCborTag(3)),
        disableBalanceCheck: values.elementAs(4),
        preferNoSetFee: values.elementAs(5),
        preferNoSetMemo: values.elementAs(6));
  }

  @override
  Web3CosmosRequestMethods get method => transaction.method;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.toCbor(),
          chainId,
          transaction.toCbor(),
          disableBalanceCheck,
          preferNoSetFee,
          preferNoSetMemo
        ]),
        type.tag);
  }

  @override
  Object? toJsWalletResponse(Web3CosmosSignTransactionResponse response) {
    return response.toJson();
  }

  @override
  Web3CosmosRequest<Web3CosmosSignTransactionResponse,
          Web3CosmosSignTransaction>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final CosmosChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3CosmosRequest<Web3CosmosSignTransactionResponse,
            Web3CosmosSignTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
