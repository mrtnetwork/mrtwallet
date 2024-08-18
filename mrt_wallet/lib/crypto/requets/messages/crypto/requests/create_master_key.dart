import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class CryptoRequestCreateMasterKey
    implements CryptoRequest<WalletMasterKeys, MessageArgsOneBytes> {
  final String mnemonic;
  final String? passphrase;
  CryptoRequestCreateMasterKey({
    required this.mnemonic,
    required this.passphrase,
  });

  factory CryptoRequestCreateMasterKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.createMasterKey.tag);
    return CryptoRequestCreateMasterKey(
        mnemonic: values.elementAt(0), passphrase: values.elementAt(1));
  }

  static WalletMasterKeys getMasterKey(
      {String? passphrase, required String mnemonic}) {
    final isValid = Bip39MnemonicValidator();
    if (!isValid.isValid(mnemonic)) {
      throw WalletExceptionConst.invalidMnemonic;
    }
    final String passPhrase = passphrase ?? '';
    final seed = Bip39SeedGenerator(Mnemonic.fromString(mnemonic));
    final List<int> seedBytes = seed.generate(passPhrase);
    final List<int> entropySeedBytes = seed.generateFromEntropy(passPhrase);
    final icarus = CardanoIcarusSeedGenerator(mnemonic).generate();
    final cardanoLegacy = CardanoByronLegacySeedGenerator(mnemonic).generate();
    final List<int> checksum = QuickCrypto.sha3256Hash(
        [...seedBytes, ...icarus, ...cardanoLegacy, ...passPhrase.codeUnits]);

    return WalletMasterKeys.setup(
        mnemonic: mnemonic,
        seed: seedBytes,
        icarus: icarus,
        cardanoLegacy: cardanoLegacy,
        checksum: checksum,
        entropySeed: entropySeedBytes);
  }

  @override
  MessageArgsOneBytes getResult() {
    final masterKey = getMasterKey(mnemonic: mnemonic, passphrase: passphrase);
    return MessageArgsOneBytes(keyOne: masterKey.toCbor().encode());
  }

  @override
  WalletMasterKeys parsResult(MessageArgsOneBytes result) {
    return WalletMasterKeys.fromCborBytesOrObject(bytes: result.keyOne);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([mnemonic, passphrase]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.createMasterKey;

  @override
  WalletMasterKeys result() {
    return getMasterKey(mnemonic: mnemonic, passphrase: passphrase);
  }
}
