import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';

class SolanaNewAddressParams implements NewAccountParams<SolAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  SolanaNewAddressParams({required this.deriveIndex, required this.coin});

  factory SolanaNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.solanaNewAddressParams.tag);
    return SolanaNewAddressParams(
      deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
          obj: values.getCborTag(0)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(1)),
    );
  }

  @override
  ISolanaAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ISolanaAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletSolanaNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.solanaNewAddressParams;
}
