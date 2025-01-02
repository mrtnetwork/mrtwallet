import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/keys/import/import_keys.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class MoneroMnemonicToPrivateKeyMessage
    extends CryptoRequest<ImportCustomKeys, MessageArgsOneBytes> {
  final String mnemonic;
  final CryptoCoins coin;
  const MoneroMnemonicToPrivateKeyMessage(
      {required this.mnemonic, required this.coin});
  factory MoneroMnemonicToPrivateKeyMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoRequestMethod.moneroMnemonicToPrivateKey.tag);
    return MoneroMnemonicToPrivateKeyMessage(
        mnemonic: values.elementAt(0),
        coin: CustomCoins.getSerializationCoin(values.elementAt(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([mnemonic, coin.toCbor()]), method.tag);
  }

  static ImportCustomKeys tonMoneroPrivateSpendKey({
    required String mnemonic,
    required CryptoCoins coin,
  }) {
    final validate = MoneroMnemonicValidator().isValid(mnemonic);
    if (!validate) {
      throw WalletExceptionConst.invalidMnemonic;
    }
    final seed = MoneroSeedGenerator(Mnemonic.fromString(mnemonic)).generate();
    final account = MoneroAccount.fromSeed(seed);
    return ImportCustomKeys(
        privateKey: account.privateSpendKey.toHex(),
        publicKey: account.privateSpendKey.publicKey.toHex(),
        coin: coin);
  }

  @override
  MessageArgsOneBytes getResult() {
    final importedKey =
        tonMoneroPrivateSpendKey(coin: coin, mnemonic: mnemonic);
    return MessageArgsOneBytes(keyOne: importedKey.toCbor().encode());
  }

  @override
  ImportCustomKeys parsResult(MessageArgsOneBytes result) {
    return ImportCustomKeys.deserialize(bytes: result.keyOne);
  }

  @override
  CryptoRequestMethod get method =>
      CryptoRequestMethod.moneroMnemonicToPrivateKey;

  @override
  ImportCustomKeys result() {
    return tonMoneroPrivateSpendKey(coin: coin, mnemonic: mnemonic);
  }
}

class MoneroMenmonicGenerateMessage
    extends CryptoRequest<String, MessageArgsOneBytes> {
  final MoneroWordsNum wordsNum;
  final MoneroLanguages language;
  const MoneroMenmonicGenerateMessage(
      {required this.wordsNum, required this.language});
  factory MoneroMenmonicGenerateMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoRequestMethod.generateMoneroMnemonic.tag);
    return MoneroMenmonicGenerateMessage(
        wordsNum: MoneroWordsNum.fromValue(values.elementAs(0)),
        language: MoneroLanguages.fromValue(values.elementAs(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([wordsNum.value, language.name]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.generateMoneroMnemonic;

  @override
  MessageArgsOneBytes getResult() {
    final mnemonic =
        MoneroMnemonicGenerator(language).fromWordsNumber(wordsNum);

    return MessageArgsOneBytes(keyOne: StringUtils.encode(mnemonic.toStr()));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return StringUtils.decode(result.keyOne);
  }

  @override
  String result() {
    return MoneroMnemonicGenerator(language).fromWordsNumber(wordsNum).toStr();
  }
}
