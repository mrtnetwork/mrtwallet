import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:ton_dart/ton_dart.dart';

class TonNewAddressParams implements NewAccountParams<TonAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;
  final TonAccountContext context;
  @override
  final AddressDerivationIndex deriveIndex;

  const TonNewAddressParams(
      {required this.deriveIndex, required this.coin, required this.context});

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
      context: TonAccountContext.deserialize(
          object: values.elemetAs<CborTagValue>(1)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }

  TonAddress toAddress(
      {required List<int> publicKey, required TonChain chain}) {
    final wallet = context.toWalletContract(publicKey: publicKey, chain: chain);
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
        CborListValue.fixedLength(
            [deriveIndex.toCbor(), context.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.tonNewAddressParams;
}
