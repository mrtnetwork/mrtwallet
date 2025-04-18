import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateNewAddressParams
    implements NewAccountParams<BaseSubstrateAddress> {
  @override
  bool get isMultiSig => false;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;

  @override
  final AddressDerivationIndex deriveIndex;

  const SubstrateNewAddressParams({required this.deriveIndex});

  factory SubstrateNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.substrateNewAddressParams.tag);
    return SubstrateNewAddressParams(
      deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
          obj: values.getCborTag(0)),
    );
  }

  BaseSubstrateAddress toAddress(
      {required List<int> publicKey,
      required int ss58Format,
      required SubstrateChainType type}) {
    return SubstrateUtils.toAddress(
        publicKey: publicKey,
        ss58Format: ss58Format,
        curve: deriveIndex.currencyCoin.conf.type,
        isEthereum: type.isEthereum);
  }

  @override
  ISubstrateAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    return ISubstrateAddress.newAccount(
        accountParams: this,
        publicKey: publicKey.keyBytes(),
        network: network.toNetwork());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor()]), type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.substrateNewAddressParams;
}
