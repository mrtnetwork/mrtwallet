import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/models/key_type.dart';

class ImportedKeyStorage with CborSerializable, Equatable {
  ImportedKeyStorage(
      {required this.checksum,
      required this.extendedPrivateKey,
      required this.coin,
      required this.publicKey,
      required this.name,
      DateTime? created,
      required this.keyType})
      : created = created ?? DateTime.now();
  final String checksum;
  final String extendedPrivateKey;
  final String publicKey;
  final String? name;
  final DateTime created;
  final CryptoCoins coin;
  final CustomKeyType keyType;
  factory ImportedKeyStorage.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CryptoKeyConst.walletCustomKey);

      final CryptoCoins coin = CustomCoins.getCoin(
        name: cbor.elementAt(4),
        proposal: cbor.elementAt(3),
      );
      return ImportedKeyStorage(
          checksum: cbor.elementAt(0),
          extendedPrivateKey: cbor.elementAt(1),
          publicKey: cbor.elementAt(2),
          coin: coin,
          created: cbor.elementAt(5),
          name: cbor.elementAt(6),
          keyType: CustomKeyType.fromName(cbor.elementAt(7)));
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          checksum,
          extendedPrivateKey,
          publicKey,
          coin.proposal.specName,
          coin.coinName,
          CborEpochIntValue(created),
          name,
          keyType.name
        ]),
        CryptoKeyConst.walletCustomKey);
  }

  @override
  List get variabels =>
      [checksum, extendedPrivateKey, coin.coinName, publicKey];

  PrivateKeyData _toBip32KeyKey(AddressDerivationIndex? key) {
    final currentCoin = key?.currencyCoin ?? coin;
    if (keyType.isPrivateKey) {
      return PrivateKeyData(
          coin: coin,
          keyName: checksum,
          key: IPrivateKey.fromHex(extendedPrivateKey, currentCoin.conf.type));
    }
    return PrivateKeyData.fromExtendedKey(
      extendedKey: extendedPrivateKey,
      coin: currentCoin,
      keyName: checksum,
    );
  }

  PrivateKeyData toKey(AddressDerivationIndex? key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    final masterKey = _toBip32KeyKey(key);
    if (key == null) {
      return masterKey;
    }
    return key.derive(masterKey, maxLevel: maxLevel);
  }
}
