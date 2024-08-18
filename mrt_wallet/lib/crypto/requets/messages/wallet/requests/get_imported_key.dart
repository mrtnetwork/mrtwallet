import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WalletRequestReadImportedKey
    implements WalletRequest<PrivateKeyData, MessageArgsOneBytes> {
  final String keyId;
  WalletRequestReadImportedKey(this.keyId);

  factory WalletRequestReadImportedKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.readImportKey.tag);
    return WalletRequestReadImportedKey(values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([keyId]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.readImportKey;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final importedKey = wallet.getImportedKey(keyId);
    return MessageArgsOneBytes(keyOne: importedKey.toCbor().encode());
  }

  @override
  PrivateKeyData parsResult(MessageArgsOneBytes result) {
    return PrivateKeyData.fromCborBytesOrObject(bytes: result.keyOne);
  }

  @override
  PrivateKeyData result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    return wallet.getImportedKey(keyId);
  }
}
