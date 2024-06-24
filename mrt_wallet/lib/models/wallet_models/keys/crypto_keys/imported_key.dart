import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/bip32_address_index.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

enum CustomKeyType {
  privateKey,
  extendedKey;

  static CustomKeyType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw const MessageException("Invalid CustomKeyType."));
  }

  bool get isPrivateKey => this == CustomKeyType.privateKey;
}

class WalletCustomKeys with CborSerializable, Equatable {
  WalletCustomKeys(
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
  factory WalletCustomKeys.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.walletCustomKey);

      final CryptoProposal proposal =
          CustomProposal.fromName(cbor.elementAt(3));
      final CryptoCoins coin =
          CustomCoins.getCoin(cbor.elementAt(4), proposal)!;
      return WalletCustomKeys(
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
        WalletModelCborTagsConst.walletCustomKey);
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

  Bip32Base toKey(Bip32AddressIndex? key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    final toKey = _toBip32KeyKey(key);
    if (key == null) return toKey;
    return key.derive(toKey, maxLevel: maxLevel);
  }
}
