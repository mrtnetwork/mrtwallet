import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class Web3SubstrateSendTransactionResponse {
  final int id;
  final String signature;
  final String? signedTransaction;
  Web3SubstrateSendTransactionResponse._(
      {required this.signature,
      required this.signedTransaction,
      required this.id});
  Web3SubstrateSendTransactionResponse(
      {this.id = 1, required List<int> signature, List<int>? signedTransaction})
      : signature = BytesUtils.toHexString(signature, prefix: "0x"),
        signedTransaction =
            BytesUtils.tryToHexString(signedTransaction, prefix: "0x");
  factory Web3SubstrateSendTransactionResponse.fromJson(
      Map<String, dynamic> json) {
    return Web3SubstrateSendTransactionResponse._(
        signature: json["signature"],
        signedTransaction: json["signedTransaction"],
        id: json["id"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "signature": signature,
      "signedTransaction": signedTransaction,
      "id": id
    };
  }
}

class Web3SubstrateSendTransaction
    extends Web3SubstrateRequestParam<Map<String, dynamic>> {
  final List<int>? assetId;
  final List<int> blockHash;
  final int blockNumber;
  final List<int> era;
  final List<int> genesisHash;
  final List<int>? metadataHash;
  final List<int> call;
  final int? mode;
  final int nonce;
  final int specVersion;
  final BigInt tip;
  final int transactionVersion;
  final List<String> signedExtensions;
  final int version;
  final bool? withSignedTransaction;
  Web3SubstrateSendTransaction._(
      {required this.assetId,
      required this.blockHash,
      required this.blockNumber,
      required this.era,
      required this.genesisHash,
      required this.metadataHash,
      required this.call,
      required this.mode,
      required this.nonce,
      required this.specVersion,
      required this.tip,
      required this.transactionVersion,
      required this.version,
      required this.withSignedTransaction,
      required this.account,
      required this.signedExtensions});
  factory Web3SubstrateSendTransaction({
    required Map<String, dynamic> json,
    required BaseSubstrateAddress address,
  }) {
    final method = Web3SubstrateRequestMethods.signTransaction;
    return Web3SubstrateSendTransaction._(
        assetId: Web3ValidatorUtils.parseHex<List<int>?>(
            key: "assetId", method: method, json: json),
        blockHash: Web3ValidatorUtils.parseHex<List<int>>(
            key: "blockHash", method: method, json: json),
        genesisHash: Web3ValidatorUtils.parseHex<List<int>>(
            key: "genesisHash", method: method, json: json),
        blockNumber: Web3ValidatorUtils.parseInt<int>(
            key: "blockNumber", method: method, json: json, sign: false),
        tip: Web3ValidatorUtils.parseBigInt<BigInt>(
            key: "tip", method: method, json: json, sign: false),
        specVersion: Web3ValidatorUtils.parseInt<int>(
            key: "specVersion", method: method, json: json, sign: false),
        nonce: Web3ValidatorUtils.parseInt<int>(
            key: "nonce", method: method, json: json, sign: false),
        mode: Web3ValidatorUtils.parseInt<int?>(
            key: "mode", method: method, json: json, sign: false),
        transactionVersion: Web3ValidatorUtils.parseInt<int>(
            key: "transactionVersion", method: method, json: json),
        version: Web3ValidatorUtils.parseInt<int>(
            key: "version", method: method, json: json, sign: false),
        call: Web3ValidatorUtils.parseHex<List<int>>(
            key: "method", method: method, json: json),
        account: address,
        era: Web3ValidatorUtils.parseHex<List<int>>(
            key: "era", method: method, json: json),
        metadataHash: Web3ValidatorUtils.parseHex<List<int>?>(
            key: "metadataHash", method: method, json: json),
        signedExtensions: Web3ValidatorUtils.parseList<List<String>, String>(
            key: 'signedExtensions', method: method, json: json),
        withSignedTransaction: Web3ValidatorUtils.parseBool<bool?>(
            key: "withSignedTransaction", method: method, json: json));
  }

  factory Web3SubstrateSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SubstrateSendTransaction._(
      account: BaseSubstrateAddress(values.elementAs(1)),
      assetId: values.elementAs(2),
      blockHash: values.elementAs(3),
      blockNumber: values.elementAs(4),
      era: values.elementAs(5),
      genesisHash: values.elementAs(6),
      metadataHash: values.elementAs(7),
      call: values.elementAs(8),
      mode: values.elementAs(9),
      nonce: values.elementAs(10),
      specVersion: values.elementAs(11),
      tip: values.elementAs(12),
      transactionVersion: values.elementAs(13),
      signedExtensions: values
          .elementAsListOf<CborStringValue>(14)
          .map((e) => e.value)
          .toList(),
      version: values.elementAs(15),
      withSignedTransaction: values.elementAs(16),
    );
  }

  @override
  Web3SubstrateRequestMethods get method =>
      Web3SubstrateRequestMethods.signTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.address,
          assetId == null ? null : CborBytesValue(assetId!),
          CborBytesValue(blockHash),
          blockNumber,
          CborBytesValue(era),
          CborBytesValue(genesisHash),
          metadataHash == null ? null : CborBytesValue(metadataHash!),
          CborBytesValue(call),
          mode,
          nonce,
          specVersion,
          tip,
          transactionVersion,
          CborListValue.fixedLength(
              signedExtensions.map((e) => CborStringValue(e)).toList()),
          version,
          withSignedTransaction
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "address": account.address,
      "assetId": BytesUtils.tryToHexString(assetId),
      "blockHash": BytesUtils.toHexString(blockHash),
      "blockNumber": blockNumber,
      "era": BytesUtils.toHexString(era),
      "genesisHash": BytesUtils.toHexString(genesisHash),
      "metadataHash": BytesUtils.tryToHexString(metadataHash),
      "mode": mode,
      "nonce": nonce,
      "specVersion": specVersion,
      "tip": tip,
      "signedExtensions": signedExtensions,
      "version": version,
      "withSignedTransaction": withSignedTransaction
    };
  }

  @override
  Web3SubstrateRequest<Map<String, dynamic>, Web3SubstrateSendTransaction>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required SubstrateChain chain}) {
    return Web3SubstrateRequest<Map<String, dynamic>,
            Web3SubstrateSendTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  @override
  final BaseSubstrateAddress account;
}
