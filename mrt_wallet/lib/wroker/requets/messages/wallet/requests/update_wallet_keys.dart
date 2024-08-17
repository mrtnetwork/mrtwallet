import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wroker/keys/models/encrypted_master.dart';
import 'package:mrt_wallet/wroker/keys/models/imported.dart';
import 'package:mrt_wallet/wroker/keys/models/master_key.dart';
import 'package:mrt_wallet/wroker/requets/argruments/argruments.dart';
import 'package:mrt_wallet/wroker/requets/messages/core/message.dart';
import 'package:mrt_wallet/wroker/requets/messages/crypto/requests/generate_master_key.dart';
import 'package:mrt_wallet/wroker/requets/messages/models/models/generate_master_key.dart';

class WalletRequestImportNewKey
    implements
        WalletRequest<CryptoGenerateMasterKeyResponse, MessageArgsTwoBytes> {
  final ImportedKeyStorage newKey;
  WalletRequestImportNewKey(this.newKey);

  factory WalletRequestImportNewKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.updateWalletKeys.tag);
    return WalletRequestImportNewKey(
        ImportedKeyStorage.fromCborBytesOrObject(obj: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([newKey.toCbor()]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.updateWalletKeys;

  @override
  MessageArgsTwoBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final newWallet = wallet.importCustomKey(newKey);
    final encryptWallet = CryptoRequestGenerateMasterKey.encryptedMasterKey(
        masterKey: newWallet, key: key);
    return MessageArgsTwoBytes(
        keyOne: encryptWallet.$1.toCbor().encode(), keyTwo: encryptWallet.$2);
  }

  @override
  CryptoGenerateMasterKeyResponse parsResult(MessageArgsTwoBytes result) {
    return CryptoGenerateMasterKeyResponse(
        masterKey:
            EncryptedMasterKey.fromCborBytesOrObject(bytes: result.keyOne),
        storageData:
            StringUtils.decode(result.keyTwo, type: StringEncoding.base64));
  }

  @override
  CryptoGenerateMasterKeyResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final newWallet = wallet.importCustomKey(newKey);
    final encryptWallet = CryptoRequestGenerateMasterKey.encryptedMasterKey(
        masterKey: newWallet, key: key);
    return CryptoGenerateMasterKeyResponse(
        masterKey: encryptWallet.$1,
        storageData:
            StringUtils.decode(encryptWallet.$2, type: StringEncoding.base64));
  }
}
