import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wroker/keys/access/private_key_response.dart';
import 'package:mrt_wallet/wroker/utils/global/utils.dart';
import 'package:mrt_wallet/wroker/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';
import 'package:mrt_wallet/wroker/keys/models/key_type.dart';
import 'package:mrt_wallet/wroker/derivation/derivation/bip32.dart';

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

      final CryptoProposal proposal =
          CustomProposal.fromName(cbor.elementAt(3));
      final CryptoCoins coin =
          CustomCoins.getCoin(cbor.elementAt(4), proposal)!;
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

  Bip32Base _toBip32KeyKey(Bip32AddressIndex? key) {
    if (keyType.isPrivateKey) {
      return BlockchainUtils.privteKeyToBip32(
          BytesUtils.fromHexString(extendedPrivateKey),
          key?.currencyCoin ?? coin);
    }
    return BlockchainUtils.extendedKeyToBip32(
        extendedKey: extendedPrivateKey, coin: key?.currencyCoin ?? coin);
  }

  PrivateKeyData toKey(Bip32AddressIndex? key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    final toKey = _toBip32KeyKey(key);

    if (key == null) {
      return PrivateKeyData.fromBip32(
          account: toKey, coin: key?.currencyCoin ?? coin, keyName: checksum);
    }
    final derivedKey = key.derive(toKey, maxLevel: maxLevel);
    return PrivateKeyData.fromBip32(
        account: derivedKey, coin: key.currencyCoin, keyName: checksum);
  }
}
