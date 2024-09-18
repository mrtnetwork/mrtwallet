import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/constant/constants/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
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
  factory Web3TonTransactionMessage.fromJson(Map<String, dynamic> json,
      {int? workchain}) {
    const method = Web3TonRequestMethods.sendTransaction;
    return Web3TonTransactionMessage(
        address: Web3ValidatorUtils.parseAddress(
            json: json,
            key: "address",
            method: method,
            onParse: (address) =>
                TonAddress(address, forceWorkchain: workchain),
            addressName: Web3TonConst.addressName),
        amount: Web3ValidatorUtils.parseBigInt(
            key: "amount", method: method, json: json),
        stateInit: Web3ValidatorUtils.parseTonCell(
            key: "stateInit", method: method, json: json),
        payload: Web3ValidatorUtils.parseTonCell(
            key: "payload", method: method, json: json));
  }
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

  Map<String, dynamic> toJson() {
    return {
      "address": address.toFriendlyAddress(),
      "amount": amount,
      "stateInit": stateInit,
      "payload": payload
    };
  }
}

class Web3TonSendTransactionResponse {
  final String boc;
  final String txHash;
  const Web3TonSendTransactionResponse(
      {required this.boc, required this.txHash});
  Map<String, dynamic> toJson() {
    return {"boc": boc, "tx_hash": txHash};
  }
}

class Web3TonSendTransaction
    extends Web3TonRequestParam<Web3TonSendTransactionResponse> {
  @override
  final TonAddress account;
  final int validUntil;
  final List<Web3TonTransactionMessage> messages;

  Web3TonSendTransaction(
      {required this.account,
      required this.validUntil,
      required List<Web3TonTransactionMessage> messages})
      : messages = messages.imutable;
  factory Web3TonSendTransaction.fromJson(
      {required Map<String, dynamic> json, required TonAddress account}) {
    const method = Web3TonRequestMethods.sendTransaction;
    return Web3TonSendTransaction(
      account: account,
      validUntil: Web3ValidatorUtils.parseInt(
          key: "validUntil", method: method, json: json),
      messages: Web3ValidatorUtils.parseList<List, dynamic>(
              key: "messages", method: method, json: json)
          .map((e) => Web3TonTransactionMessage.fromJson(
              Web3ValidatorUtils.isValidMap<String, dynamic,
                  Map<String, dynamic>>(e),
              workchain: account.workChain))
          .toList(),
    );
  }

  factory Web3TonSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3TonSendTransaction(
        account: TonAddress(values.elementAt(1)),
        messages: values
            .elemetAs<CborListValue>(2)
            .value
            .cast<CborTagValue>()
            .map((e) => Web3TonTransactionMessage.deserialize(object: e))
            .toList(),
        validUntil: values.elementAt(3));
  }

  @override
  Web3TonRequestMethods get method => Web3TonRequestMethods.sendTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.toFriendlyAddress(),
          CborListValue.fixedLength(messages.map((e) => e.toCbor()).toList()),
          validUntil
        ]),
        type.tag);
  }

  @override
  Map<String, String?> toJson() {
    return {
      "account": account.toFriendlyAddress(),
      "messages":
          StringUtils.fromJson(messages.map((e) => e.toJson()).toList()),
      "validUntil": validUntil.toRadix16
    };
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
          required TheOpenNetworkChain chain}) {
    return Web3TonRequest<Web3TonSendTransactionResponse,
            Web3TonSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
