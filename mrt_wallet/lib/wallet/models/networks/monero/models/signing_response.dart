import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/utils/utils.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class MoneroTxDestinationWithProof with CborSerializable {
  final MoneroAddress address;
  final IntegerBalance amount;
  final String proof;
  MoneroTxDestinationWithProof({
    required this.address,
    required this.proof,
    required BigInt amount,
  }) : amount = IntegerBalance(amount, MoneroConst.decimal,
            imutable: true, allowNegative: false);
  factory MoneroTxDestinationWithProof.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroTxDestinationWithProof);
    return MoneroTxDestinationWithProof(
      address: MoneroAddress(values.elementAs(0)),
      amount: values.elementAs(1),
      proof: values.elementAs(2),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborStringValue(address.address),
          amount.balance,
          CborStringValue(proof)
        ]),
        CborTagsConst.moneroTxDestinationWithProof);
  }
}

class MoneroSignedTxData with CborSerializable {
  final String txID;
  final List<MoneroPrivateKey> txKeys;
  final List<MoneroAccountIndex> indexes;
  MoneroSignedTxData(
      {required String txID,
      required List<MoneroPrivateKey> txKeys,
      required List<MoneroAccountIndex> indexes})
      : txID = QuickCryptoValidator.asValidHexBytes(txID,
            lengthInBytes: MoneroConst.txHashLength),
        txKeys = txKeys.immutable,
        indexes = indexes.immutable;
  factory MoneroSignedTxData.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroSignedTxData);
    return MoneroSignedTxData(
        txID: String.fromCharCodes(values.elementAs(0)),
        txKeys: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => MoneroPrivateKey.fromBytes(e.value))
            .toList(),
        indexes: values
            .elementAsListOf<CborBytesValue>(2)
            .map((e) => MoneroAccountIndex.deserialize(e.value))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(txID.codeUnits),
          CborListValue.fixedLength(
              txKeys.map((e) => CborBytesValue(e.key)).toList()),
          CborListValue.fixedLength(
              indexes.map((e) => CborBytesValue(e.serialize())).toList()),
        ]),
        CborTagsConst.moneroSignedTxData);
  }
}

class MoneroSigningTxResponse with CborSerializable {
  final MoneroSignedTxData txData;
  final List<MoneroTxDestinationWithProof> proofs;
  final String txBytes;
  MoneroSigningTxResponse({
    required this.txData,
    required List<MoneroTxDestinationWithProof> proofs,
    required String txHex,
  })  : proofs = proofs.immutable,
        txBytes = QuickCryptoValidator.asValidHexBytes(txHex);
  factory MoneroSigningTxResponse.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroSigningTxResponse);
    return MoneroSigningTxResponse(
        txData: MoneroSignedTxData.deserialize(obj: values.getCborTag(0)),
        proofs: values
            .elementAsListOf<CborObject>(1)
            .map((e) => MoneroTxDestinationWithProof.deserialize(obj: e))
            .toList(),
        txHex: String.fromCharCodes(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          txData.toCbor(),
          CborListValue.fixedLength(proofs.map((e) => e.toCbor()).toList()),
          CborBytesValue(txBytes.codeUnits)
        ]),
        CborTagsConst.moneroSigningTxResponse);
  }
}
