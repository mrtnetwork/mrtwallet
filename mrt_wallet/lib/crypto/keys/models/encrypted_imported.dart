import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/constant/tags.dart';
import 'package:mrt_wallet/crypto/keys/models/key_type.dart';

class EncryptedCustomKey with Equatable, CborSerializable {
  final String publicKey;
  final String id;
  final CryptoCoins coin;
  final DateTime created;
  final String? name;
  final CustomKeyType keyType;
  const EncryptedCustomKey(
      {required this.publicKey,
      required this.coin,
      required this.id,
      required this.created,
      required this.name,
      required this.keyType});
  factory EncryptedCustomKey.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.encryptedCustomKey);
    final CryptoCoins coin = CustomCoins.getCoin(
      name: cbor.elementAt(3),
      proposal: cbor.elementAt(2),
    );
    return EncryptedCustomKey(
        publicKey: cbor.elementAt(0),
        id: cbor.elementAt(1),
        coin: coin,
        created: cbor.elementAt(4),
        name: cbor.elementAt(5),
        keyType: CustomKeyType.fromName(cbor.elementAt(6)));
  }

  bool get allowDerivation {
    if (keyType.isPrivateKey && coin == Bip44Coins.moneroEd25519Slip) {
      return false;
    }
    return true;
  }

  @override
  List get variabels => [publicKey, id, coin, keyType.name];

  bool canUseFor(CryptoCoins coin) {
    if (this.coin == coin) return true;
    if (!keyType.isPrivateKey) return false;
    if (coin == Bip44Coins.moneroEd25519Slip) {
      return this.coin == coin;
    }
    return this.coin.conf.type == coin.conf.type;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          publicKey,
          id,
          coin.proposal.specName,
          coin.coinName,
          CborEpochIntValue(created),
          name ?? const CborNullValue(),
          keyType.name,
        ]),
        CryptoKeyConst.encryptedCustomKey);
  }
}
