import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/tron/addresses/multisig.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/tron/addresses/tron.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:on_chain/on_chain.dart';

class TronNewAddressParams implements NewAccountParams<TronAddress> {
  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  TronNewAddressParams({required this.deriveIndex, required this.coin});

  factory TronNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.tronNewAddressParams.tag);
    return TronNewAddressParams(
      deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
          obj: values.getCborTag(0)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(1)),
    );
  }
  @override
  ITronAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ITronAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletTronNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.tronNewAddressParams;
}

class TronMultisigNewAddressParams implements TronNewAddressParams {
  const TronMultisigNewAddressParams({
    required this.multiSigAccount,
    required this.masterAddress,
    required this.coin,
  });
  @override
  bool get isMultiSig => true;

  final TronAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex = const MultiSigAddressIndex();

  final TronMultiSignatureAddress multiSigAccount;
  @override
  final CryptoCoins coin;

  factory TronMultisigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.tronMultisigNewAddressParams.tag);
    return TronMultisigNewAddressParams(
      masterAddress: TronAddress(values.elementAt(0)),
      multiSigAccount: values
          .getCborTag(1)!
          .to((e) => TronMultiSignatureAddress.fromCborBytesOrObject(obj: e)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterAddress.toAddress(),
          multiSigAccount.toCbor(),
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  ITronMultisigAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ITronMultisigAddress.newAccount(
        accountParams: this, network: network as WalletTronNetwork);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.tronMultisigNewAddressParams;
}
