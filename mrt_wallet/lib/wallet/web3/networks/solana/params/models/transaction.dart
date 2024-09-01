import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/constant/constants/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/params/core/request.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaSendTransactionOptions with CborSerializable {
  final int? maxRetries;
  final bool skipPreflight;
  final String? commitment;
  final int? minContextSlot;
  final bool signers;
  const Web3SolanaSendTransactionOptions(
      {this.maxRetries,
      this.skipPreflight = false,
      this.commitment,
      this.minContextSlot,
      this.signers = false});
  factory Web3SolanaSendTransactionOptions.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final values = CborSerializable.cborTagValue<CborListValue>(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3SolanaConst.sendTransactionDataConfigTag);
    return Web3SolanaSendTransactionOptions(
      maxRetries: values.elemetAs(0),
      skipPreflight: values.elemetAs(1),
      commitment: values.elemetAs(2),
      minContextSlot: values.elementAt(3),
    );
  }
  factory Web3SolanaSendTransactionOptions.fromJson(Map<String, dynamic> json) {
    return Web3SolanaSendTransactionOptions(
        commitment: json["preflightCommitment"],
        skipPreflight: json["skipPreflight"],
        maxRetries: json["maxRetries"],
        minContextSlot: json["minContextSlot"],
        signers: json["signers"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "maxRetries": maxRetries,
      "preflightCommitment": skipPreflight,
      "commitment": commitment,
      "minContextSlot": minContextSlot,
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [maxRetries, skipPreflight, commitment, minContextSlot]),
        Web3SolanaConst.sendTransactionDataConfigTag);
  }

  ///  skipPreflight: false, maxRetries: 5
}

class Web3SolanaSendTransactionData with CborSerializable {
  final SolAddress account;
  final int id;
  final List<int> messageBytes;

  Web3SolanaSendTransactionData({
    required this.account,
    required List<int> messageByte,
    required this.id,
  }) : messageBytes = BytesUtils.toBytes(messageByte, unmodifiable: true);
  factory Web3SolanaSendTransactionData.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final values = CborSerializable.cborTagValue<CborListValue>(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3SolanaConst.sendTransactionDataTag);
    return Web3SolanaSendTransactionData(
        account: SolAddress(values.elementAt(0)),
        messageByte: values.elementAt(1),
        id: values.elementAt(2));
  }

  Map<String, dynamic> toJson() {
    return {
      "account": account.address,
      "message": BytesUtils.toHexString(messageBytes)
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [account.address, CborBytesValue(messageBytes), id]),
        Web3SolanaConst.sendTransactionDataTag);
  }
}

class Web3SolanaSendTransaction
    extends Web3SolanaRequestParam<List<Map<String, dynamic>>> {
  final List<Web3SolanaSendTransactionData> messages;
  final Web3SolanaSendTransactionOptions? sendConfig;
  bool get isSend => sendConfig != null;

  @override
  SolAddress get account => messages.first.account;

  Web3SolanaSendTransaction({required this.messages, required this.sendConfig});

  factory Web3SolanaSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SolanaSendTransaction(
        messages: values
            .elemetAs<CborListValue>(1)
            .castValue<CborTagValue>()
            .map((e) => Web3SolanaSendTransactionData.deserialize(object: e))
            .toList(),
        sendConfig: values.getCborTag(2)?.to(
            (e) => Web3SolanaSendTransactionOptions.deserialize(object: e)));
  }

  @override
  Web3SolanaRequestMethods get method =>
      Web3SolanaRequestMethods.signTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          CborListValue.fixedLength(messages.map((e) => e.toCbor()).toList()),
          sendConfig?.toCbor()
        ]),
        type.tag);
  }

  @override
  Map<String, String?> toJson() {
    return {
      "messages":
          StringUtils.fromJson(messages.map((e) => e.toJson()).toList()),
    };
  }

  @override
  Web3SolanaRequest<List<Map<String, dynamic>>, Web3SolanaSendTransaction>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required SolanaChain chain}) {
    return Web3SolanaRequest<List<Map<String, dynamic>>,
            Web3SolanaSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
