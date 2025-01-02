import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/coins/serialization/extension.dart';
import 'package:mrt_wallet/crypto/constant/tags.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/keys/access/monero_public_key.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';

import 'view_keys.dart';

class MoneroPrivateKeyData extends CryptoPrivateKeyData {
  @override
  final CryptoCoins coin;
  @override
  final String privateKey;
  final MoneroPrivateKey viewPrivateKey;
  final MoneroPrivateKey spendPrivateKey;
  @override
  final String? extendedKey;
  @override
  final String? wif;
  @override
  final String keyName;

  @override
  MoneroPrivateKeysView get toViewKey => MoneroPrivateKeysView(
      extendKey: extendedKey,
      privateKey: privateKey,
      wif: wif,
      keyName: keyName,
      keyType: type,
      spendPrivateKey: spendPrivateKey.toHex(),
      viewPrivateKey: viewPrivateKey.toHex(),
      curve: coin.conf.type);

  MoneroAccount toMoneroAccount() {
    return MoneroAccount.fromPrivateSpendKey(spendPrivateKey.key);
  }

  @override
  final MoneroPublicKeyData publicKey;
  factory MoneroPrivateKeyData.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessMoneroPrivateKeyResponse);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    return MoneroPrivateKeyData._(
      privateKey: values.elementAs(1),
      extendedKey: values.elementAs(2),
      coin: coin,
      wif: values.elementAs(3),
      keyName: values.elementAs(4),
      publicKey: MoneroPublicKeyData.deserialize(obj: values.getCborTag(5)),
      spendPrivateKey: MoneroPrivateKey.fromBytes(values.elementAs(6)),
      viewPrivateKey: MoneroPrivateKey.fromBytes(values.elementAs(7)),
    );
  }

  const MoneroPrivateKeyData._(
      {required this.privateKey,
      required this.extendedKey,
      required this.coin,
      required this.wif,
      required this.keyName,
      required this.publicKey,
      required this.viewPrivateKey,
      required this.spendPrivateKey});
  factory MoneroPrivateKeyData.fromBip32({
    required Bip32Base account,
    required CryptoCoins coin,
    required String keyName,
  }) {
    final moneroAccount =
        MoneroAccount.fromBip44PrivateKey(account.privateKey.raw);
    final wifKey =
        BlockchainUtils.toWif(privateKey: account.privateKey.raw, coin: coin);
    return MoneroPrivateKeyData._(
      privateKey: account.privateKey.toHex(),
      extendedKey: account.privateKey.toExtended,
      coin: coin,
      wif: wifKey,
      keyName: keyName,
      viewPrivateKey: moneroAccount.privVkey,
      spendPrivateKey: moneroAccount.privateSpendKey,
      publicKey:
          MoneroPublicKeyData.fromBip32(account: account, keyName: keyName),
    );
  }
  factory MoneroPrivateKeyData({
    required MoneroPrivateKey spendPrivateKey,
    required CryptoCoins coin,
    required String keyName,
  }) {
    final moneroAccount =
        MoneroAccount.fromPrivateSpendKey(spendPrivateKey.key);
    final wifKey =
        BlockchainUtils.toWif(privateKey: spendPrivateKey.key, coin: coin);
    return MoneroPrivateKeyData._(
      privateKey: spendPrivateKey.toHex(),
      extendedKey: null,
      coin: coin,
      wif: wifKey,
      keyName: keyName,
      viewPrivateKey: moneroAccount.privVkey,
      spendPrivateKey: moneroAccount.privateSpendKey,
      publicKey:
          MoneroPublicKeyData(privateKey: spendPrivateKey, keyName: keyName),
    );
  }

  factory MoneroPrivateKeyData.fromExtendedKey(
      {required String extendedKey,
      required CryptoCoins coin,
      required String keyName}) {
    final account = BlockchainUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey, coin: coin);
    return MoneroPrivateKeyData.fromBip32(
        account: account, coin: coin, keyName: keyName);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          privateKey,
          extendedKey,
          wif ?? const CborNullValue(),
          keyName,
          publicKey.toCbor(),
          CborBytesValue(spendPrivateKey.key),
          CborBytesValue(viewPrivateKey.key),
        ]),
        type.tag);
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

  @override
  CryptoPrivateKeyDataType get type => CryptoPrivateKeyDataType.monero;
}
