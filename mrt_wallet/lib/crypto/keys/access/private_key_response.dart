import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/bip/ecc/keys/i_keys.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';

import 'public_key_response.dart';

class PrivateKeyData implements CryptoPrivateKeyData {
  @override
  final CryptoCoins coin;
  @override
  final String privateKey;
  @override
  final String? extendedKey;
  final String? wif;
  @override
  final String keyName;
  @override
  final CryptoPublicKeyData publicKey;
  const PrivateKeyData._(
      {required this.privateKey,
      required this.extendedKey,
      required this.coin,
      required this.wif,
      required this.keyName,
      required this.publicKey});
  factory PrivateKeyData.fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName}) {
    final wifKey =
        BlockchainUtils.toWif(privateKey: account.privateKey.raw, coin: coin);
    return PrivateKeyData._(
        privateKey: account.privateKey.toHex(),
        extendedKey: account.privateKey.toExtended,
        coin: coin,
        wif: wifKey,
        keyName: keyName,
        publicKey: PublicKeyData.fromBip32(account: account, keyName: keyName));
  }
  factory PrivateKeyData.fromExtendedKey(
      {required String extendedKey,
      required CryptoCoins coin,
      required String keyName}) {
    final bipKey = BlockchainUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey, coin: coin);
    final wifKey =
        BlockchainUtils.toWif(privateKey: bipKey.privateKey.raw, coin: coin);
    return PrivateKeyData._(
        privateKey: bipKey.privateKey.toHex(),
        extendedKey: bipKey.privateKey.toExtended,
        coin: coin,
        wif: wifKey,
        keyName: keyName,
        publicKey: PublicKeyData.fromBip32(account: bipKey, keyName: keyName));
  }
  factory PrivateKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeyResponse);
    final CryptoCoins coin = CustomCoins.getCoin(
      name: cbor.elementAt(1),
      proposal: cbor.elementAt(0),
    );
    return PrivateKeyData._(
        privateKey: cbor.elementAt(2),
        extendedKey: cbor.elementAt(3),
        coin: coin,
        wif: cbor.elementAt(4),
        keyName: cbor.elementAt(5),
        publicKey:
            PublicKeyData.fromCborBytesOrObject(obj: cbor.getCborTag(6)));
  }

  factory PrivateKeyData(
      {required CryptoCoins coin,
      required String keyName,
      required IPrivateKey key}) {
    return PrivateKeyData._(
        privateKey: key.toHex(),
        extendedKey: null,
        coin: coin,
        wif: BlockchainUtils.toWif(privateKey: key.raw, coin: coin),
        keyName: keyName,
        publicKey:
            PublicKeyData(key: key.publicKey, coin: coin, keyName: keyName));
  }
  factory PrivateKeyData.fromSeed(
      {required CryptoCoins coin,
      required String keyName,
      required List<int> seedBytes}) {
    if (coin is BipCoins) {
      final key =
          BlockchainUtils.seedToBipKey(seedBytes: seedBytes, coin: coin);
      return PrivateKeyData.fromBip32(
          account: key, coin: coin, keyName: keyName);
    }
    final substrate = BlockchainUtils.seedToSubstratePrivateKey(
        seedBytes: seedBytes, coin: coin);
    return PrivateKeyData(coin: coin, keyName: keyName, key: substrate);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          privateKey,
          extendedKey,
          wif ?? const CborNullValue(),
          keyName,
          publicKey.toCbor()
        ]),
        CryptoKeyConst.accessPrivateKeyResponse);
  }

  @override
  Bip32Base toBipKey() {
    if (extendedKey == null) {
      return BlockchainUtils.privteKeyToBip32(
          privateKey: privateKey, coin: coin);
    }
    return BlockchainUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey!, coin: coin);
  }

  @override
  List<int> privateKeyBytes() {
    return BytesUtils.fromHexString(privateKey);
  }
}
