import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonTransactionMessage with CborSerializable {
  final TonAddress address;
  final BigInt amount;
  final Cell? stateInit;
  final Cell? payload;

  const Web3TonTransactionMessage(
      {required this.address,
      required this.amount,
      required this.stateInit,
      required this.payload});

  factory Web3TonTransactionMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3TonConst.sendTransactionMessagesTag);
    final List<int>? stateInitBytes = values.elementAt(2);
    final List<int>? payloadBytes = values.elementAt(3);
    return Web3TonTransactionMessage(
        address: TonAddress(values.elementAt(0)),
        amount: values.elementAt(1),
        stateInit:
            stateInitBytes == null ? null : Cell.fromBytes(stateInitBytes),
        payload: payloadBytes == null ? null : Cell.fromBytes(payloadBytes));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          address.toFriendlyAddress(),
          amount,
          stateInit == null ? null : CborBytesValue(stateInit!.toBoc()),
          payload == null ? null : CborBytesValue(payload!.toBoc()),
        ]),
        Web3TonConst.sendTransactionMessagesTag);
  }
}

class Web3TonSendTransactionResponse {
  final String message;
  final String? txHash;
  const Web3TonSendTransactionResponse({required this.message, this.txHash});
  Map<String, dynamic> toJson() {
    return {"message": message, "tx_hash": txHash};
  }

  factory Web3TonSendTransactionResponse.fromJson(Map<String, dynamic> json) {
    return Web3TonSendTransactionResponse(
        message: json["message"], txHash: json["tx_hash"]);
  }
}

class Web3TonSendTransaction
    extends Web3TonRequestParam<Web3TonSendTransactionResponse> {
  @override
  final Web3TonChainAccount account;
  final int validUntil;
  final List<Web3TonTransactionMessage> messages;

  Web3TonSendTransaction._(
      {required this.account,
      required this.validUntil,
      required this.method,
      required List<Web3TonTransactionMessage> messages})
      : messages = messages.imutable;
  factory Web3TonSendTransaction(
      {required Web3TonChainAccount account,
      required int validUntil,
      required Web3NetworkRequestMethods method,
      required List<Web3TonTransactionMessage> messages}) {
    switch (method) {
      case Web3TonRequestMethods.sendTransaction:
      case Web3TonRequestMethods.signTransaction:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (messages.isEmpty || messages.length > 4) {
      throw Web3TonExceptionConstant.invalidMessageLength;
    }
    return Web3TonSendTransaction._(
        account: account,
        validUntil: validUntil,
        method: method as Web3TonRequestMethods,
        messages: messages);
  }

  factory Web3TonSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAs(0));
    return Web3TonSendTransaction(
        account: Web3TonChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        messages: values
            .elementAs<CborListValue>(2)
            .value
            .cast<CborTagValue>()
            .map((e) => Web3TonTransactionMessage.deserialize(object: e))
            .toList(),
        validUntil: values.elementAt(3),
        method: method);
  }

  @override
  final Web3TonRequestMethods method;

  bool get isExcute => method == Web3TonRequestMethods.sendTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.toCbor(),
          CborListValue.fixedLength(messages.map((e) => e.toCbor()).toList()),
          validUntil
        ]),
        type.tag);
  }

  @override
  Object? toJsWalletResponse(Web3TonSendTransactionResponse response) {
    return response.toJson();
  }

  @override
  Web3TonRequest<Web3TonSendTransactionResponse, Web3TonSendTransaction>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final TheOpenNetworkChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3TonRequest<Web3TonSendTransactionResponse,
            Web3TonSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
