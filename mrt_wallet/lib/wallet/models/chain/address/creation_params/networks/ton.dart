import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/utils/ton/ton.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:ton_dart/ton_dart.dart';

class TonNewAddressParams implements NewAccountParams<TonAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;
  final WalletVersion version;
  final int? subWalletId;
  @override
  final AddressDerivationIndex deriveIndex;

  final bool bouncable;

  const TonNewAddressParams(
      {required this.deriveIndex,
      required this.version,
      required this.bouncable,
      required this.coin,
      this.subWalletId});

  factory TonNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.tonNewAddressParams.tag);
    return TonNewAddressParams(
      deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
          obj: values.getCborTag(0)),
      version: WalletVersion.fromValue(values.elementAt(1)),
      subWalletId: values.elementAt(2),
      bouncable: values.elementAt(3),
      coin: CustomCoins.getSerializationCoin(values.elementAt(4)),
    );
  }

  TonAddress toAddress({required List<int> publicKey, required int workChain}) {
    final wallet = TonUtils.fromVersion(
        publicKey: publicKey,
        workChain: workChain,
        version: version,
        subWalletId: subWalletId,
        bouncable: bouncable);
    return wallet.address;
  }

  @override
  ITonAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ITonAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletTonNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          deriveIndex.toCbor(),
          version.name,
          subWalletId,
          bouncable,
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.tonNewAddressParams;
}
