import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';

class MoneroNewAddressParams implements NewAccountParams<MoneroAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  final int minor;
  final int major;
  final MoneroViewAccountDetails? addrDetails;
  final MoneroNetwork network;

  const MoneroNewAddressParams(
      {required this.deriveIndex,
      required this.minor,
      required this.major,
      required this.coin,
      this.addrDetails,
      required this.network});
  MoneroNewAddressParams copyWith(
      {CryptoCoins? coin,
      int? minor,
      int? major,
      AddressDerivationIndex? deriveIndex,
      MoneroViewAccountDetails? addrDetails,
      MoneroNetwork? network}) {
    return MoneroNewAddressParams(
        deriveIndex: deriveIndex ?? this.deriveIndex,
        minor: minor ?? this.minor,
        major: major ?? this.major,
        coin: coin ?? this.coin,
        addrDetails: addrDetails ?? this.addrDetails,
        network: network ?? this.network);
  }

  factory MoneroNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.moneroNewAddressParams.tag);
    return MoneroNewAddressParams(
        deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        major: values.elementAs(1),
        minor: values.elementAs(2),
        coin: CustomCoins.getSerializationCoin(values.elementAt(3)),
        addrDetails: values
            .getCborTag(4)
            ?.to((e) => MoneroViewAccountDetails.deserialize(object: e)),
        network: MoneroNetwork.fromName(values.elementAs(5)));
  }

  @override
  IMoneroAddress toAccount(
      WalletNetwork<NetworkCoinParams<APIProvider>> network,
      CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    return IMoneroAddress.newAccount(
        accountParams: this, network: network.toNetwork());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          deriveIndex.toCbor(),
          major,
          minor,
          coin.toCbor(),
          addrDetails?.toCbor(),
          network.name
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.moneroNewAddressParams;
}
