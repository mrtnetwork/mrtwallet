import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class TronMultiSigSignerDetais with Equatable, CborSerializable {
  TronMultiSigSignerDetais._(
      {required this.publicKey, required this.weight, required this.keyIndex});

  factory TronMultiSigSignerDetais(
      {required List<int> publicKey,
      required AddressDerivationIndex keyIndex,
      required BigInt weight}) {
    return TronMultiSigSignerDetais._(
        publicKey: BytesUtils.toHexString(publicKey),
        weight: weight,
        keyIndex: keyIndex);
  }
  factory TronMultiSigSignerDetais.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tronMultiSigSignerAddress);

    final List<int> publicKey = cbor.elementAt(0);
    final BigInt weight = cbor.elementAt(1);
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    return TronMultiSigSignerDetais(
        publicKey: publicKey, weight: weight, keyIndex: keyIndex);
  }

  final String publicKey;
  final BigInt weight;

  final AddressDerivationIndex keyIndex;
  String get path => keyIndex.toString();

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(BytesUtils.fromHexString(publicKey)),
          weight,
          keyIndex.toCbor()
        ]),
        WalletModelCborTagsConst.tronMultiSigSignerAddress);
  }

  @override
  List get variabels => [publicKey, weight, keyIndex];
}

class TronMultiSignatureAddress with Equatable, CborSerializable {
  final List<TronMultiSigSignerDetais> signers;
  final BigInt threshold;
  final int? permissionID;

  TronMultiSignatureAddress._(
      {required this.signers,
      required this.threshold,
      required this.permissionID});

  factory TronMultiSignatureAddress(
      {required BigInt threshold,
      required List<TronMultiSigSignerDetais> signers,
      required int? permissionID}) {
    final sumWeight =
        signers.fold(BigInt.zero, (sum, signer) => sum + signer.weight);

    if (sumWeight < threshold) {
      throw WalletException(
          'The total weight of the signatories should reach the threshold');
    }

    return TronMultiSignatureAddress._(
        signers: signers, threshold: threshold, permissionID: permissionID);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(signers.map((e) => e.toCbor()).toList()),
          threshold,
          permissionID,
        ]),
        WalletModelCborTagsConst.tronMultiSignaturAddress);
  }

  factory TronMultiSignatureAddress.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tronMultiSignaturAddress);
    final List<dynamic> signersList = cbor.elementAt(0);
    final List<TronMultiSigSignerDetais> signers = signersList
        .map<TronMultiSigSignerDetais>(
            (e) => TronMultiSigSignerDetais.fromCborBytesOrObject(obj: e))
        .toList();
    final BigInt threshHold = cbor.elementAt(1);
    final int? permissionID = cbor.elementAt(2);
    return TronMultiSignatureAddress._(
        signers: signers, threshold: threshHold, permissionID: permissionID);
  }

  @override
  List get variabels => [threshold, signers, permissionID];
}
