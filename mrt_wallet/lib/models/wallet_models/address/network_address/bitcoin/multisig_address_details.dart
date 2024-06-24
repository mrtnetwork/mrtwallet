import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class BitcoinMultiSigSignerDetais
    with Equatable, CborSerializable
    implements MultiSignatureSigner {
  BitcoinMultiSigSignerDetais._(
      {required this.publicKey, required int weight, required this.keyIndex})
      : _wieght = weight;

  factory BitcoinMultiSigSignerDetais(
      {required List<int> publicKey,
      required AddressDerivationIndex keyIndex,
      int weight = 1}) {
    if (!BytesUtils.bytesEqual(
        ECPublic.fromBytes(publicKey).toCompressedBytes(), publicKey)) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (weight < 1 || weight > 16) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return BitcoinMultiSigSignerDetais._(
        publicKey: BytesUtils.toHexString(publicKey),
        weight: weight,
        keyIndex: keyIndex);
  }
  factory BitcoinMultiSigSignerDetais.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitcoinMultiSigSignerAddress);

    final List<int> publicKey = cbor.elementAt(0);
    final int weight = cbor.elementAt(1);
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    return BitcoinMultiSigSignerDetais(
        publicKey: publicKey, weight: weight, keyIndex: keyIndex);
  }
  @override
  final String publicKey;
  int _wieght;
  @override
  int get weight => _wieght;

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
        WalletModelCborTagsConst.bitcoinMultiSigSignerAddress);
  }

  @override
  List get variabels => [publicKey, weight, keyIndex];
}

class BitcoinMultiSignatureAddress
    with CborSerializable
    implements MultiSignatureAddress {
  @override
  final List<BitcoinMultiSigSignerDetais> signers;

  /// Threshold is the minimum number of signatures required to spend the bitcoins associated
  /// with this address.
  @override
  final int threshold;

  /// ScriptDetails provides details about the multi-signature script used in transactions,
  /// including "OP_M", compressed public keys, "OP_N", and "OP_CHECKMULTISIG."
  @override
  final Script multiSigScript;

  BitcoinMultiSignatureAddress._(
      {required this.signers,
      required this.threshold,
      required this.multiSigScript});

  /// CreateMultiSignatureAddress creates a new instance of a MultiSignatureAddress, representing
  /// a multi-signature Bitcoin address configuration. It allows you to specify the minimum number
  /// of required signatures (threshold), provide the collection of signers participating in the
  /// multi-signature scheme, and specify the address type.
  factory BitcoinMultiSignatureAddress({
    required int threshold,
    required List<BitcoinMultiSigSignerDetais> signers,
    required BitcoinAddressType addressType,
  }) {
    final sumWeight = signers.fold(0, (sum, signer) => sum + signer.weight);
    if (threshold > 16 || threshold < 1) {
      throw ArgumentError('The threshold should be between 1 and 16');
    }
    if (sumWeight > 16) {
      throw ArgumentError(
          'The total weight of the owners should not exceed 16');
    }
    if (sumWeight < threshold) {
      throw ArgumentError(
          'The total weight of the signatories should reach the threshold');
    }
    final multiSigScript = <Object>['OP_$threshold'];
    for (final signer in signers) {
      for (var w = 0; w < signer.weight; w++) {
        multiSigScript.add(signer.publicKey);
      }
    }
    multiSigScript.addAll(['OP_$sumWeight', 'OP_CHECKMULTISIG']);
    final script = Script(script: multiSigScript);

    return BitcoinMultiSignatureAddress._(
        signers: signers, threshold: threshold, multiSigScript: script);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(signers.map((e) => e.toCbor()).toList()),
          threshold,
          CborListValue<String>.fixedLength(multiSigScript.script.cast())
        ]),
        WalletModelCborTagsConst.bitcoinMultiSignaturAddress);
  }

  factory BitcoinMultiSignatureAddress.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitcoinMultiSignaturAddress);

    final List<dynamic> signersList = cbor.elementAt(0);
    final List<BitcoinMultiSigSignerDetais> signers = signersList
        .map<BitcoinMultiSigSignerDetais>(
            (e) => BitcoinMultiSigSignerDetais.fromCborBytesOrObject(obj: e))
        .toList();
    final int threshHold = cbor.elementAt(1);
    final List<dynamic> scriptsOpcode = cbor.elementAt(2);
    final List<String> scriptDetails =
        scriptsOpcode.map<String>((e) => e.value).toList();

    return BitcoinMultiSignatureAddress._(
        multiSigScript: Script(script: scriptDetails),
        signers: signers,
        threshold: threshHold);
  }

  @override
  BitcoinBaseAddress toP2wshAddress({required BasedUtxoNetwork network}) {
    return P2wshAddress.fromScript(script: multiSigScript);
  }

  @override
  BitcoinBaseAddress toP2wshInP2shAddress({required BasedUtxoNetwork network}) {
    final p2wsh = toP2wshAddress(network: network);
    return P2shAddress.fromScript(
        script: p2wsh.toScriptPubKey(), type: P2shAddressType.p2wshInP2sh);
  }

  List get variabels => [threshold, multiSigScript.toHex()];

  @override
  BitcoinBaseAddress toP2shAddress(
      [P2shAddressType addressType = P2shAddressType.p2pkhInP2sh]) {
    if (!MultiSignatureAddress.legacySupportP2shTypes.contains(addressType)) {
      throw MessageException(
          "invalid p2sh type please use one of them ${MultiSignatureAddress.legacySupportP2shTypes.map((e) => "$e").join(", ")}");
    }

    if (addressType.hashLength == 32) {
      return P2shAddress.fromHash160(
          addrHash: BytesUtils.toHexString(
              QuickCrypto.sha256DoubleHash(multiSigScript.toBytes())),
          type: addressType);
    }
    return P2shAddress.fromScript(script: multiSigScript, type: addressType);
  }

  @override
  BitcoinBaseAddress fromType(
      {required BasedUtxoNetwork network,
      required BitcoinAddressType addressType}) {
    switch (addressType) {
      case SegwitAddresType.p2wsh:
        return toP2wshAddress(network: network);
      case P2shAddressType.p2wshInP2sh:
        return toP2wshInP2shAddress(network: network);
      case P2shAddressType.p2pkhInP2sh:
      case P2shAddressType.p2pkhInP2sh32:
      case P2shAddressType.p2pkhInP2shwt:
      case P2shAddressType.p2pkhInP2sh32wt:
        return toP2shAddress(addressType as P2shAddressType);
      default:
        throw ArgumentError(
            "invalid multisig address type. use of of them [BitcoinAddressType.p2wsh, BitcoinAddressType.p2wshInP2sh, BitcoinAddressType.p2pkhInP2sh]");
    }
  }
}
