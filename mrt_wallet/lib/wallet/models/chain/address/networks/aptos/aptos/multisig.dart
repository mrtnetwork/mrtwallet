import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/utils/aptos/aptos.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/networks/aptos/models/types.dart';
import 'package:on_chain/on_chain.dart';

class AptosMultisigAccountPublicKeyInfo with CborSerializable, Equatable {
  /// public key bytes
  final List<int> publicKey;

  /// Aptos crypto key scheme (ED25519,Secp256k1)
  final AptosSupportKeyScheme keyScheme;

  /// bip32 key index for generate private key.
  final Bip32AddressIndex keyIndex;
  AptosMultisigAccountPublicKeyInfo._(
      {required List<int> publicKey,
      required this.keyScheme,
      required this.keyIndex})
      : publicKey = publicKey.asImmutableBytes;
  factory AptosMultisigAccountPublicKeyInfo.create(
      {required List<int> publicKey,
      required AptosSupportKeyScheme keyScheme,
      required Bip32AddressIndex keyIndex}) {
    try {
      switch (keyScheme) {
        case AptosSupportKeyScheme.multiEd25519:
        case AptosSupportKeyScheme.multiKey:
          throw WalletException("invalid_key_scheme");
        default:
          break;
      }
      return AptosMultisigAccountPublicKeyInfo._(
          publicKey: publicKey, keyScheme: keyScheme, keyIndex: keyIndex);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails_(messsage: e.toString());
    }
  }
  factory AptosMultisigAccountPublicKeyInfo.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.aptosMultisigAccountPublicKey);
    return AptosMultisigAccountPublicKeyInfo._(
        publicKey: values.elementAs(0),
        keyScheme: AptosSupportKeyScheme.fromValue(values.elementAs(1)),
        keyIndex:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        [CborBytesValue(publicKey), keyScheme.value, keyIndex.toCbor()],
        CborTagsConst.aptosMultisigAccountPublicKey);
  }

  String toHex() {
    return BlockchainUtils.toPublicKeyHex(publicKey, keyIndex.currencyCoin);
  }

  @override
  List get variabels => [keyIndex, keyScheme];

  /// convert to aptos public key for creating authenticated.
  PUBLICKEY toAptosPublicKey<PUBLICKEY extends AptosCryptoPublicKey>() {
    final AptosCryptoPublicKey publicKey = switch (keyScheme) {
      AptosSupportKeyScheme.ed25519 ||
      AptosSupportKeyScheme.signleKeyEd25519 =>
        AptosED25519PublicKey.fromBytes(this.publicKey),
      AptosSupportKeyScheme.signleKeySecp256k1 =>
        AptosSecp256k1PublicKey.fromBytes(this.publicKey),
      _ => throw WalletException("invalid_key_scheme")
    };
    return publicKey.cast();
  }

  /// convert to IPublic key for generating address
  PUBLICKEY toPublicKey<PUBLICKEY extends IPublicKey>() {
    final IPublicKey publicKey = switch (keyScheme) {
      AptosSupportKeyScheme.ed25519 ||
      AptosSupportKeyScheme.signleKeyEd25519 =>
        Ed25519PublicKey.fromBytes(this.publicKey),
      AptosSupportKeyScheme.signleKeySecp256k1 =>
        Secp256k1PublicKeyEcdsa.fromBytes(this.publicKey),
      _ => throw WalletException("invalid_key_scheme")
    };
    if (publicKey is! PUBLICKEY) {
      throw WalletException.invalidArgruments(
          ["$PUBLICKEY", publicKey.runtimeType.toString()]);
    }
    return publicKey;
  }
}

class AptosMultisigAccountInfo with CborSerializable {
  /// List of public keys
  final List<AptosMultisigAccountPublicKeyInfo> publicKeys;

  /// required signature
  final int requiredSignature;

  /// multisig keyscheme. (MultiEd25519 or MultiKey)
  final AptosSupportKeyScheme keyScheme;
  AptosMultisigAccountInfo._(
      {required List<AptosMultisigAccountPublicKeyInfo> publicKeys,
      required this.requiredSignature,
      required this.keyScheme})
      : publicKeys = publicKeys.immutable;
  factory AptosMultisigAccountInfo.create(
      {required List<AptosMultisigAccountPublicKeyInfo> publicKeys,
      required AptosSupportKeyScheme keyScheme,
      required int requiredSignature}) {
    try {
      switch (keyScheme) {
        case AptosSupportKeyScheme.multiEd25519:
          AptosMultiEd25519AccountPublicKey(
              threshold: requiredSignature,
              publicKeys: publicKeys
                  .map((e) => e.toAptosPublicKey<AptosED25519PublicKey>())
                  .toList());
          break;
        case AptosSupportKeyScheme.multiKey:
          AptosMultiKeyAccountPublicKey(
              requiredSignature: requiredSignature,
              publicKeys: publicKeys.map((e) => e.toAptosPublicKey()).toList());
          break;
        default:
          throw WalletException("invalid_key_scheme");
      }
      return AptosMultisigAccountInfo._(
          publicKeys: publicKeys,
          requiredSignature: requiredSignature,
          keyScheme: keyScheme);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails_(messsage: e.toString());
    }
  }
  factory AptosMultisigAccountInfo.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.aptosMultisigAccountInfo);
    return AptosMultisigAccountInfo._(
        publicKeys: values
            .elementAsListOf<CborTagValue>(0)
            .map(
                (e) => AptosMultisigAccountPublicKeyInfo.deserialize(object: e))
            .toList(),
        requiredSignature: values.elementAs(1),
        keyScheme: AptosSupportKeyScheme.fromValue(values.elementAs(2)));
  }

  /// generate mutlisig public key for create authenticated.
  PUBLICKEY
      toAptosMutlisigPublicKey<PUBLICKEY extends AptosAccountPublicKey>() {
    final publicKey = switch (keyScheme) {
      AptosSupportKeyScheme.multiEd25519 => AptosMultiEd25519AccountPublicKey(
          publicKeys: publicKeys
              .map((e) => e.toAptosPublicKey<AptosED25519PublicKey>())
              .toList(),
          threshold: requiredSignature),
      AptosSupportKeyScheme.multiKey => AptosMultiKeyAccountPublicKey(
          publicKeys: publicKeys.map((e) => e.toAptosPublicKey()).toList(),
          requiredSignature: requiredSignature),
      _ => throw WalletException("invalid_key_scheme")
    };
    return publicKey.cast();
  }

  /// generate aptos authenticated for transaction.
  AptosAccountAuthenticator createAccountAuthenticated(
      List<AptosAnySignature> signatures) {
    assert(signatures.length == requiredSignature, "invalid signature length.");
    if (signatures.length < requiredSignature) {
      throw WalletException("insufficient_signatures");
    }
    final bitmap = AptosUtils.createSignatureBitMap(
        List.generate(requiredSignature, (i) => i));
    switch (keyScheme) {
      case AptosSupportKeyScheme.multiEd25519:
        return AptosAccountAuthenticatorMultiEd25519(
            publicKey: toAptosMutlisigPublicKey(),
            signature: AptosMultiEd25519Signature(
                signatures: signatures
                    .map((e) => AptosEd25519Signature(e.signatureBytes()))
                    .toList(),
                bitmap: bitmap));
      case AptosSupportKeyScheme.multiKey:
        return AptosAccountAuthenticatorMultiKey(
            publicKey: toAptosMutlisigPublicKey(),
            signature:
                AptosMultiKeySignature(signatures: signatures, bitmap: bitmap));
      default:
        throw WalletException("invalid_key_scheme");
    }
  }

  /// generate aptos address
  AptosAddress generateAddress() {
    final String address = switch (keyScheme) {
      AptosSupportKeyScheme.multiEd25519 => AptosAddrEncoder()
          .encodeMultiEd25519Key(
              publicKeys: publicKeys
                  .map((e) => e.toPublicKey<Ed25519PublicKey>())
                  .toList(),
              threshold: requiredSignature),
      AptosSupportKeyScheme.multiKey => AptosAddrEncoder().encodeMultiKey(
          publicKeys: publicKeys.map((e) => e.toPublicKey()).toList(),
          requiredSignature: requiredSignature),
      _ => throw WalletException("invalid_key_scheme")
    };
    return AptosAddress(address);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborListValue.fixedLength(publicKeys.map((e) => e.toCbor()).toList()),
      requiredSignature,
      keyScheme.value
    ], CborTagsConst.aptosMultisigAccountInfo);
  }
}
