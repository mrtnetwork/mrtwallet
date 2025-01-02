import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/ethereum/ethereum.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class EthereumNewAddressParams implements NewAccountParams<ETHAddress> {
  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  const EthereumNewAddressParams(
      {required this.deriveIndex, required this.coin});
  factory EthereumNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.ethereumNewAddressParamss.tag);
    return EthereumNewAddressParams(
      deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
          obj: values.getCborTag(0)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(1)),
    );
  }

  @override
  IEthAddress toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    return IEthAddress.newAccount(
        accountParams: this,
        publicKey: publicKey.keyBytes(),
        network: network.toNetwork());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.ethereumNewAddressParamss;
}
