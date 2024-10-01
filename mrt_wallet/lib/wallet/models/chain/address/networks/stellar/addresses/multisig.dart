import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';

class StellarMultiSigSignerDetails with Equatable, CborSerializable {
  const StellarMultiSigSignerDetails._(
      {required this.publicKey, required this.weight, required this.keyIndex});

  factory StellarMultiSigSignerDetails(
      {required List<int> publicKey,
      required Bip32AddressIndex keyIndex,
      required int weight}) {
    return StellarMultiSigSignerDetails._(
        publicKey: BytesUtils.toHexString(publicKey),
        weight: weight,
        keyIndex: keyIndex);
  }
  factory StellarMultiSigSignerDetails.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.stellarMultiSigSignerAddress);

    final List<int> publicKey = cbor.elementAt(0);
    final int weight = cbor.elementAt(1);
    final keyIndex =
        Bip32AddressIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    return StellarMultiSigSignerDetails(
        publicKey: publicKey, weight: weight, keyIndex: keyIndex);
  }

  final String publicKey;
  final int weight;

  final Bip32AddressIndex keyIndex;
  String get path => keyIndex.toString();

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(BytesUtils.fromHexString(publicKey)),
          weight,
          keyIndex.toCbor()
        ]),
        CborTagsConst.stellarMultiSigSignerAddress);
  }

  @override
  List get variabels => [publicKey, weight, keyIndex];
}

class StellarMultiSignatureAddress with Equatable, CborSerializable {
  final List<StellarMultiSigSignerDetails> signers;

  final int threshold;
  final bool isRegular;

  StellarMultiSignatureAddress._(
      {required this.signers,
      required this.threshold,
      required this.isRegular});

  factory StellarMultiSignatureAddress(
      {required int threshold,
      required List<StellarMultiSigSignerDetails> signers,
      required bool isRegularKey}) {
    final sumWeight = signers.fold(0, (sum, signer) => sum + signer.weight);

    if (sumWeight < threshold) {
      throw ArgumentError(
          'The total weight of the signatories should reach the threshold');
    }

    return StellarMultiSignatureAddress._(
        signers: signers, threshold: threshold, isRegular: isRegularKey);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(signers.map((e) => e.toCbor()).toList()),
          threshold,
          CborBoleanValue(isRegular)
        ]),
        CborTagsConst.stellarMultiSignaturAddress);
  }

  factory StellarMultiSignatureAddress.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.stellarMultiSignaturAddress);
    final List<dynamic> signersList = cbor.elementAt(0);
    final List<StellarMultiSigSignerDetails> signers = signersList
        .map<StellarMultiSigSignerDetails>(
            (e) => StellarMultiSigSignerDetails.fromCborBytesOrObject(obj: e))
        .toList();
    final int threshHold = cbor.elementAt(1);
    final bool isRegularKey = cbor.elementAt(2);
    return StellarMultiSignatureAddress._(
        signers: signers, threshold: threshHold, isRegular: isRegularKey);
  }

  @override
  List get variabels => [threshold, signers];
}
