import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

enum MrtBackupTypes {
  wallet(CborTagsConst.mrtBackupWallet, "wallets"),
  mnemonic(CborTagsConst.mrtBackupMnemonic, "mnemonic"),
  privatekey(CborTagsConst.mrtBackupPrivateKey, "private_key"),
  wif(CborTagsConst.mrtBackupWif, "wif"),
  keystore([], "keystore"),
  extendedKey(CborTagsConst.mrtBackupExtendedKey, "extended_private_key");

  final List<int> tag;
  final String value;
  const MrtBackupTypes(this.tag, this.value);

  static MrtBackupTypes fromValue(List<int> tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag));
  }

  SecretWalletEncoding get encoding {
    switch (this) {
      case MrtBackupTypes.keystore:
        return SecretWalletEncoding.json;
      default:
        return SecretWalletEncoding.cbor;
    }
  }

  bool get isPrivateKey =>
      this == MrtBackupTypes.privatekey || this == MrtBackupTypes.keystore;

  List<int> toEncryptionBytes(String data) {
    switch (this) {
      case MrtBackupTypes.mnemonic:
        return StringUtils.encode(data);
      case MrtBackupTypes.keystore:
      case MrtBackupTypes.privatekey:
      case MrtBackupTypes.wallet:
        return BytesUtils.fromHexString(data);
      default:
        return Base58Decoder.checkDecode(data);
    }
  }

  String fromDecyrptBytes(List<int> decryptedKeyBytes) {
    switch (this) {
      case MrtBackupTypes.mnemonic:
        return StringUtils.decode(decryptedKeyBytes);
      case MrtBackupTypes.privatekey:
      case MrtBackupTypes.wallet:
      case MrtBackupTypes.keystore:
        return BytesUtils.toHexString(decryptedKeyBytes);

      default:
        return Base58Encoder.checkEncode(decryptedKeyBytes);
    }
  }
}
