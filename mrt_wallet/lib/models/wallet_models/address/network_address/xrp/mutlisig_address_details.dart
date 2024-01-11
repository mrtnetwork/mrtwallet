import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class RippleMultiSigSignerDetais with Equatable, CborSerializable {
  const RippleMultiSigSignerDetais._(
      {required this.publicKey, required this.weight, required this.keyIndex});

  factory RippleMultiSigSignerDetais(
      {required List<int> publicKey,
      required AddressDerivationIndex keyIndex,
      required int weight}) {
    return RippleMultiSigSignerDetais._(
        publicKey: BytesUtils.toHexString(publicKey),
        weight: weight,
        keyIndex: keyIndex);
  }
  factory RippleMultiSigSignerDetais.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.rippleMultiSigSignerAddress);

    final List<int> publicKey = cbor.getIndex(0);
    final int weight = cbor.getIndex(1);
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    return RippleMultiSigSignerDetais(
        publicKey: publicKey, weight: weight, keyIndex: keyIndex);
  }

  final String publicKey;
  final int weight;

  final AddressDerivationIndex keyIndex;
  String get path => keyIndex.path;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(BytesUtils.fromHexString(publicKey)),
          weight,
          keyIndex.toCbor()
        ]),
        WalletModelCborTagsConst.rippleMultiSigSignerAddress);
  }

  @override
  List get variabels => [publicKey, weight, keyIndex];
}

class RippleMultiSignatureAddress with Equatable, CborSerializable {
  final List<RippleMultiSigSignerDetais> signers;

  final int threshold;
  final bool isRegular;

  RippleMultiSignatureAddress._(
      {required this.signers,
      required this.threshold,
      required this.isRegular});

  factory RippleMultiSignatureAddress(
      {required int threshold,
      required List<RippleMultiSigSignerDetais> signers,
      required bool isRegularKey}) {
    final sumWeight = signers.fold(0, (sum, signer) => sum + signer.weight);

    if (sumWeight < threshold) {
      throw ArgumentError(
          'The total weight of the signatories should reach the threshold');
    }

    return RippleMultiSignatureAddress._(
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
        WalletModelCborTagsConst.rippleMultiSignaturAddress);
  }

  factory RippleMultiSignatureAddress.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.rippleMultiSignaturAddress);
    final List<dynamic> signersList = cbor.getIndex(0);
    final List<RippleMultiSigSignerDetais> signers = signersList
        .map<RippleMultiSigSignerDetais>(
            (e) => RippleMultiSigSignerDetais.fromCborBytesOrObject(obj: e))
        .toList();
    final int threshHold = cbor.getIndex(1);
    final bool isRegularKey = cbor.getIndex(2);
    return RippleMultiSignatureAddress._(
        signers: signers, threshold: threshHold, isRegular: isRegularKey);
  }

  @override
  List get variabels => [threshold, signers];
}
