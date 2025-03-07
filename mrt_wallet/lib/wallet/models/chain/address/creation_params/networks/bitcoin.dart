import 'package:bitcoin_base/bitcoin_base.dart'
    show BitcoinAddressType, BitcoinBaseAddress;
import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class BitcoinNewAddressParams implements NewAccountParams<BitcoinBaseAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
  final PubKeyModes keyType;
  @override
  final CryptoCoins coin;

  const BitcoinNewAddressParams(
      {required this.deriveIndex,
      required this.bitcoinAddressType,
      required this.coin,
      required this.keyType});
  factory BitcoinNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.bitcoinNewAddressParams.tag);
    return BitcoinNewAddressParams(
        deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        bitcoinAddressType: BitcoinAddressType.fromValue(values.elementAt(1)),
        coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
        keyType: PubKeyModes.fromValue(values.elementAs(3)));
  }

  @override
  IBitcoinAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    return IBitcoinAddress.newAccount(
        accountParams: this,
        publicKey: publicKey.keyBytes(mode: keyType),
        network: network.toNetwork());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          deriveIndex.toCbor(),
          bitcoinAddressType.value,
          coin.toCbor(),
          keyType.value
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.bitcoinNewAddressParams;
}

class BitcoinMultiSigNewAddressParams implements BitcoinNewAddressParams {
  @override
  final BitcoinAddressType bitcoinAddressType;
  final BitcoinMultiSignatureAddress multiSignatureAddress;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;
  @override
  final CryptoCoins coin;

  @override
  PubKeyModes get keyType =>
      throw UnsupportedError("key type must be implements on signers.");

  const BitcoinMultiSigNewAddressParams({
    required this.bitcoinAddressType,
    required this.multiSignatureAddress,
    required this.coin,
  }) : deriveIndex = const MultiSigAddressIndex();

  factory BitcoinMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.bitcoinMultiSigNewAddressParams.tag);
    return BitcoinMultiSigNewAddressParams(
      bitcoinAddressType: BitcoinAddressType.fromValue(values.elementAt(0)),
      multiSignatureAddress: BitcoinMultiSignatureAddress.fromCborBytesOrObject(
          obj: values.getCborTag(1)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }

  @override
  IBitcoinAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    return IBitcoinMultiSigAddress.newAccount(
        accountParam: this, network: network.toNetwork());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          bitcoinAddressType.value,
          multiSignatureAddress.toCbor(),
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.bitcoinMultiSigNewAddressParams;
}
