import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';

import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'signing_response.dart';

typedef OnSignRequest = Future<GlobalSignResponse> Function(SignRequest);

abstract class SignRequest with CborSerializable {
  final AddressDerivationIndex index;
  final SigningRequestNetwork network;
  const SignRequest({required this.index, required this.network});
  factory SignRequest.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final network = SigningRequestNetwork.fromTag(tag.tags);
    return switch (network) {
      SigningRequestNetwork.bitcoin ||
      SigningRequestNetwork.bitcoinCash =>
        BitcoinSigning.deserialize(object: tag),
      SigningRequestNetwork.cosmos =>
        CosmosSigningRequest.deserialize(object: tag),
      SigningRequestNetwork.monero =>
        MoneroSigningRequest.deserialize(object: tag),
      _ => GlobalSignRequest.deserialize(object: tag)
    };
  }
  T cast<T extends SignRequest>() {
    if (this is! T) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return this as T;
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
  stellar([32, 109]),
  monero([32, 110]),
  bitcoinCash([32, 111]),
  aptos([32, 112]),
  sui([32, 113]);

  final List<int> tag;
  const SigningRequestNetwork(this.tag);
  static SigningRequestNetwork fromTag(List<int> tag) {
    return values.firstWhere(
        (element) => BytesUtils.bytesEqual(tag, element.tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

class BitcoinSigning extends GlobalSignRequest {
  final int sighash;
  final bool useTaproot;
  final bool useBchSchnorr;
  BitcoinSigning(
      {required super.digest,
      required this.sighash,
      required this.useTaproot,
      required Bip32AddressIndex super.index,
      required super.network,
      required this.useBchSchnorr})
      : assert(
            network == SigningRequestNetwork.bitcoin ||
                network == SigningRequestNetwork.bitcoinCash,
            "invalid bitcoin network."),
        super._();

  factory BitcoinSigning.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: object, hex: hex);
    final network = SigningRequestNetwork.fromTag(tag.tags);
    if (network != SigningRequestNetwork.bitcoin &&
        network != SigningRequestNetwork.bitcoinCash) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    final CborListValue values = tag.getList;
    return BitcoinSigning(
        digest: values.elementAt(1),
        sighash: values.elementAt(2),
        useTaproot: values.elementAt(3),
        index:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(0)),
        network: network,
        useBchSchnorr: values.elementAs(4));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [index.toCbor(), digest, sighash, useTaproot, useBchSchnorr]),
        network.tag);
  }
}

class GlobalSignRequest extends SignRequest {
  final List<int> digest;
  GlobalSignRequest._({
    required List<int> digest,
    required super.network,
    required super.index,
  }) : digest = digest.asImmutableBytes;

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
  factory GlobalSignRequest.aptos({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.aptos, index: index);
  }
  factory GlobalSignRequest.sui({
    required List<int> digest,
    required Bip32AddressIndex index,
  }) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.sui, index: index);
  }
  factory GlobalSignRequest.stellar(
      {required List<int> digest, required Bip32AddressIndex index}) {
    return GlobalSignRequest._(
        digest: digest, network: SigningRequestNetwork.stellar, index: index);
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

class CosmosSigningRequest extends SignRequest {
  final List<int> digest;
  final CosmosKeysAlgs alg;
  CosmosSigningRequest._({
    required List<int> digest,
    required super.network,
    required super.index,
    required this.alg,
  }) : digest = digest.asImmutableBytes;
  factory CosmosSigningRequest({
    required List<int> digest,
    required AddressDerivationIndex index,
    required CosmosKeysAlgs alg,
  }) {
    if (!CosmosKeysAlgs.supportedAlgs.contains(alg)) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (alg.coin(ChainType.mainnet).conf.type != index.currencyCoin.conf.type) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return CosmosSigningRequest._(
        digest: digest,
        network: SigningRequestNetwork.cosmos,
        index: index,
        alg: alg);
  }
  factory CosmosSigningRequest.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: SigningRequestNetwork.cosmos.tag);
    final index =
        AddressDerivationIndex.fromCborBytesOrObject(obj: values.getCborTag(0));
    final List<int> digest = values.elementAt(1);
    final CosmosKeysAlgs alg = CosmosKeysAlgs.fromName(values.elementAs(2));
    return CosmosSigningRequest(digest: digest, index: index, alg: alg);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([index.toCbor(), digest, alg.name]),
        network.tag);
  }
}

class MoneroSigningRequest extends SignRequest {
  final List<MoneroTxDestination> destinations;
  final BigInt fee;
  final MoneroTxDestination? change;
  final List<SpendablePayment<MoneroLockedPayment>> utxos;

  MoneroSigningRequest(
      {required List<MoneroTxDestination> destinations,
      required this.fee,
      this.change,
      required List<SpendablePayment<MoneroLockedPayment>> utxos,
      required super.index})
      : destinations = destinations.immutable,
        utxos = utxos.immutable,
        super(network: SigningRequestNetwork.monero);
  factory MoneroSigningRequest.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: SigningRequestNetwork.monero.tag);

    return MoneroSigningRequest(
        index:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(0)),
        destinations: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => MoneroTxDestination.deserialize(e.value))
            .toList(),
        fee: values.elementAs(2),
        change: values.elemetMybeAs<MoneroTxDestination, CborBytesValue>(
            3, (e) => MoneroTxDestination.deserialize(e.value)),
        utxos: values
            .elementAsListOf<CborBytesValue>(4)
            .map((e) =>
                SpendablePayment<MoneroLockedPayment>.deserialize(e.value))
            .toList()
            .cast());
  }

  List<MoneroAccountIndex> getAccountsIndexes() {
    return utxos.map((e) => e.payment.output.accountIndex).toSet().toList();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          index.toCbor(),
          CborListValue.fixedLength(
              destinations.map((e) => CborBytesValue(e.serialize())).toList()),
          fee,
          change == null
              ? const CborNullValue()
              : CborBytesValue(change!.serialize()),
          CborListValue.fixedLength(
              utxos.map((e) => CborBytesValue(e.serialize())).toList()),
        ]),
        network.tag);
  }
}
