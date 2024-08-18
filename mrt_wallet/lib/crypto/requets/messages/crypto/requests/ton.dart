import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/keys/import/import_keys.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/utils/ton/ton.dart';

class TonMnemonicToPrivateKeyMessage
    implements CryptoRequest<ImportCustomKeys, MessageArgsOneBytes> {
  final String mnemonic;
  final String? password;
  final bool validateTonMnemonic;
  final CryptoCoins coin;
  const TonMnemonicToPrivateKeyMessage(
      {required this.mnemonic,
      required this.password,
      required this.validateTonMnemonic,
      required this.coin});
  factory TonMnemonicToPrivateKeyMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoRequestMethod.tonMnemonicToPrivateKey.tag);
    return TonMnemonicToPrivateKeyMessage(
        mnemonic: values.elementAt(0),
        password: values.elementAt(1),
        validateTonMnemonic: values.elementAt(2),
        coin: CustomCoins.getSerializationCoin(values.elementAt(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          mnemonic,
          password ?? const CborNullValue(),
          validateTonMnemonic,
          coin.toCbor()
        ]),
        method.tag);
  }

  static ImportCustomKeys tonMnemonicToPrivateKey(
      {required CryptoCoins coin,
      required String mnemonic,
      required String? password,
      required bool validateTonMnemonic}) {
    final key = TonUtils.generateTonPrivateKeyFromSeed(
        mnemonic: mnemonic,
        password: password,
        validateTonMnemonic: validateTonMnemonic);
    return ImportCustomKeys(
        privateKey: key.toHex(),
        publicKey: key.toPublicKey().toHex(),
        coin: coin);
  }

  @override
  MessageArgsOneBytes getResult() {
    // final key = TonUtils.generateTonPrivateKeyFromSeed(
    //     mnemonic: mnemonic,
    //     password: password,
    //     validateTonMnemonic: validateTonMnemonic);
    // final importedKey = ImportCustomKeys(
    //     privateKey: key.toHex(),
    //     publicKey: key.toPublicKey().toHex(),
    //     coin: coin);
    final importedKey = tonMnemonicToPrivateKey(
        coin: coin,
        mnemonic: mnemonic,
        password: password,
        validateTonMnemonic: validateTonMnemonic);
    return MessageArgsOneBytes(keyOne: importedKey.toCbor().encode());
  }

  @override
  ImportCustomKeys parsResult(MessageArgsOneBytes result) {
    return ImportCustomKeys.deserialize(bytes: result.keyOne);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.tonMnemonicToPrivateKey;

  @override
  ImportCustomKeys result() {
    return tonMnemonicToPrivateKey(
        coin: coin,
        mnemonic: mnemonic,
        password: password,
        validateTonMnemonic: validateTonMnemonic);
  }
}

class TonMenmonicGenerateMessage
    implements CryptoRequest<String, MessageArgsOneBytes> {
  final String? password;
  final int wordsNum;
  const TonMenmonicGenerateMessage(
      {required this.password, required this.wordsNum});
  factory TonMenmonicGenerateMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoRequestMethod.generateMnemonic.tag);
    return TonMenmonicGenerateMessage(
        password: values.elementAt(0), wordsNum: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [password ?? const CborNullValue(), wordsNum]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.generateMnemonic;

  @override
  MessageArgsOneBytes getResult() {
    final mnemonic =
        TonUtils.generateTonMnemonic(wordsNum: wordsNum, password: password);

    return MessageArgsOneBytes(keyOne: StringUtils.encode(mnemonic));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return StringUtils.decode(result.keyOne);
  }

  @override
  String result() {
    return TonUtils.generateTonMnemonic(wordsNum: wordsNum, password: password);
  }
}
