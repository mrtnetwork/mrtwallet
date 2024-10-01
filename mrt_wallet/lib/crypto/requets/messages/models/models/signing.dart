import 'package:blockchain_utils/cbor/cbor.dart';

import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'signing_response.dart';

typedef OnSignRequest = Future<GlobalSignResponse> Function(SignRequest);

abstract class SignRequest with CborSerializable {
  abstract final List<int> digest;
  abstract final AddressDerivationIndex index;
  abstract final SigningRequestNetwork network;
  factory SignRequest.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final network = SigningRequestNetwork.fromTag(tag.tags);
    if (network == SigningRequestNetwork.bitcoin) {
      return BitcoinSigning.deserialize(object: tag);
    }
    return GlobalSignRequest.deserialize(object: tag);
  }
}

enum SigningRequestNetwork {
  bitcoin([32, 100]),
  eth([32, 101]),
  ripple([32, 102]),
  cardano([32, 103]),
  ton([32, 104]),
  cosmos([32, 105]),
  solana([32, 106]),
  tron([32, 107]),
  substrate([32, 108]),
  stellar([32, 109]);

  final List<int> tag;
  const SigningRequestNetwork(this.tag);
  static SigningRequestNetwork fromTag(List<int> tag) {
    return values.firstWhere(
        (element) => BytesUtils.bytesEqual(tag, element.tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

class BitcoinSigning implements SignRequest {
  @override
  final List<int> digest;
  @override
  final Bip32AddressIndex index;
  final int sighash;
  final bool useTaproot;
  BitcoinSigning(
      {required List<int> digest,
      required this.sighash,
      required this.useTaproot,
      required this.index})
      : digest = BytesUtils.toBytes(digest);

  factory BitcoinSigning.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      hex: hex,
      object: object,
      tags: SigningRequestNetwork.bitcoin.tag,
    );
    return BitcoinSigning(
      digest: values.elementAt(1),
      sighash: values.elementAt(2),
      useTaproot: values.elementAt(3),
      index: Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(0)),
    );
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [index.toCbor(), digest, sighash, useTaproot]),
        network.tag);
  }

  @override
  SigningRequestNetwork get network => SigningRequestNetwork.bitcoin;
}

class GlobalSignRequest implements SignRequest {
  @override
  final List<int> digest;
  @override
  final SigningRequestNetwork network;
  @override
  final AddressDerivationIndex index;
  GlobalSignRequest._({
    required List<int> digest,
    required this.network,
    required this.index,
  }) : digest = BytesUtils.toBytes(digest);

  factory GlobalSignRequest.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final CborListValue values = tag.getList;
    final index =
        AddressDerivationIndex.fromCborBytesOrObject(obj: values.getCborTag(0));
    final List<int> digest = values.elementAt(1);
    final network = SigningRequestNetwork.fromTag(tag.tags);
    return GlobalSignRequest._(digest: digest, network: network, index: index);
  }

  factory GlobalSignRequest.eth({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.eth, index: index);
  }
  factory GlobalSignRequest.ripple({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.ripple, index: index);
  }
  factory GlobalSignRequest.tron({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.tron, index: index);
  }
  factory GlobalSignRequest.solana({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.solana, index: index);
  }
  factory GlobalSignRequest.stellar({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.stellar, index: index);
  }
  factory GlobalSignRequest.cosmos({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.cosmos, index: index);
  }
  factory GlobalSignRequest.ton({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.ton, index: index);
  }
  factory GlobalSignRequest.cardano({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.cardano, index: index);
  }
  factory GlobalSignRequest.substrate(
      {required List<int> digest, required AddressDerivationIndex index}) {
    if (index.isMultiSig) {
      throw WalletExceptionConst.multiSigDerivationNotSuported;
    }
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.substrate, index: index);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([index.toCbor(), digest]), network.tag);
  }
}
