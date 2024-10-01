import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarNewAddressParams implements NewAccountParams<StellarAddress> {
  @override
  bool get isMultiSig => false;

  EllipticCurveTypes get curve => coin.conf.type;
  @override
  final AddressDerivationIndex deriveIndex;

  final BigInt? id;
  @override
  final CryptoCoins coin;
  const StellarNewAddressParams(
      {required this.deriveIndex, required this.coin, this.id});

  factory StellarNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.stellarNewAddressParams.tag);
    return StellarNewAddressParams(
      deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
          obj: values.getCborTag(0)),
      id: values.elementAt(1),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }
  @override
  IStellarAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IStellarAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletStellarNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), id, coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.stellarNewAddressParams;
}

class StellarMultiSigNewAddressParams implements StellarNewAddressParams {
  @override
  bool get isMultiSig => true;

  final StellarAccountAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex = const MultiSigAddressIndex();

  final StellarMultiSignatureAddress multiSigAccount;

  @override
  final BigInt? id;
  @override
  EllipticCurveTypes get curve => throw UnimplementedError();

  @override
  final CryptoCoins coin;

  const StellarMultiSigNewAddressParams(
      {required this.multiSigAccount,
      required this.masterAddress,
      required this.coin,
      this.id});
  factory StellarMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.stellarMultiSigNewAddressParams.tag);
    return StellarMultiSigNewAddressParams(
      masterAddress: StellarAccountAddress(values.elementAt(0)),
      multiSigAccount: StellarMultiSignatureAddress.fromCborBytesOrObject(
          obj: values.getCborTag(1)),
      id: values.elementAt(1),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }

  @override
  IStellarMultisigAddress toAccount(
      WalletNetwork network, List<int> publicKey) {
    return IStellarMultisigAddress.newAccount(
        accountParams: this, network: network as WalletStellarNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterAddress.toString(),
          multiSigAccount.toCbor(),
          id,
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.stellarMultiSigNewAddressParams;
}
