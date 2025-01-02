import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/constant/tags.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';

import 'view_keys.dart';

class MoneroPublicKeyData extends CryptoPublicKeyData {
  @override
  final String? extendedKey;
  @override
  final String comprossed;
  @override
  final String? uncomprossed = null;
  final MoneroPublicKey spendPublicKey;
  final MoneroPublicKey viewPublicKey;
  final MoneroPrivateKey viewPrivateKey;
  @override
  final String? chainCode;
  @override
  final String keyName;

  @override
  PublicKeysView get toViewKey => MoneroPublicKeysView(
      extendKey: extendedKey,
      comprossed: comprossed,
      uncomprossed: uncomprossed,
      chainCode: chainCode,
      spendPublicKey: spendPublicKey.toHex(),
      viewPublicKey: viewPublicKey.toHex(),
      keyName: keyName,
      keyType: type);

  MoneroPublicKeyData._(
      {required this.extendedKey,
      required this.keyName,
      required this.spendPublicKey,
      required this.viewPublicKey,
      required this.viewPrivateKey,
      required this.chainCode,
      required this.comprossed});
  factory MoneroPublicKeyData.fromBip32(
      {required Bip32Base account, required String keyName}) {
    final moneroAccount =
        MoneroAccount.fromBip44PrivateKey(account.privateKey.raw);
    return MoneroPublicKeyData._(
        extendedKey: account.publicKey.toExtended,
        keyName: keyName,
        chainCode: account.chainCode.toHex(),
        spendPublicKey: moneroAccount.publicSpendKey,
        viewPrivateKey: moneroAccount.privateViewKey,
        viewPublicKey: moneroAccount.publicViewKey,
        comprossed: account.publicKey.toHex());
  }
  factory MoneroPublicKeyData(
      {required MoneroPrivateKey privateKey, required String keyName}) {
    final moneroAccount = MoneroAccount.fromPrivateSpendKey(privateKey.key);
    return MoneroPublicKeyData._(
        extendedKey: null,
        keyName: keyName,
        chainCode: null,
        spendPublicKey: moneroAccount.publicSpendKey,
        viewPrivateKey: moneroAccount.privateViewKey,
        viewPublicKey: moneroAccount.publicViewKey,
        comprossed: moneroAccount.publicSpendKey.toHex());
  }
  factory MoneroPublicKeyData.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessMoneroPublicKeyResponse);
    return MoneroPublicKeyData._(
        extendedKey: values.elementAs(0),
        keyName: values.elementAs(1),
        chainCode: values.elementAs(2),
        spendPublicKey: MoneroPublicKey.fromBytes(values.elementAs(3)),
        viewPrivateKey: MoneroPrivateKey.fromBytes(values.elementAs(4)),
        viewPublicKey: MoneroPublicKey.fromBytes(values.elementAs(5)),
        comprossed: values.elementAs(6));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          extendedKey,
          keyName,
          chainCode,
          CborBytesValue(spendPublicKey.key),
          CborBytesValue(viewPrivateKey.key),
          CborBytesValue(viewPublicKey.key),
          comprossed
        ]),
        type.tag);
  }

  @override
  CryptoPublicKeyDataType get type => CryptoPublicKeyDataType.monero;
}
