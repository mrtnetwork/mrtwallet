import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wroker/coins/coins.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';
import 'package:mrt_wallet/wroker/keys/import/import_keys.dart';
import 'package:mrt_wallet/wroker/messages/argruments/argruments.dart';
import 'package:mrt_wallet/wroker/utils/ton/ton.dart';

enum TonRequestMethod {
  generateMnemonic(CryptoKeyConst.generateToneMenemonic),
  tonMnemonicToPrivateKey(CryptoKeyConst.tonMnemonicToPrivateKey);

  final List<int> tag;
  const TonRequestMethod(this.tag);
  static TonRequestMethod fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidRequest);
  }
}

abstract class TonNetworkRequestArgs<T, A extends MessageArgs>
    implements MessageArgsNetwork<T, A> {
  abstract final TonRequestMethod request;
  factory TonNetworkRequestArgs.deserialize(
      {List<int>? bytes, CborObject? object}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object);
    final request = TonRequestMethod.fromTag(decode.tags);
    final TonNetworkRequestArgs args;
    switch (request) {
      case TonRequestMethod.generateMnemonic:
        args = TonMenmonicGenerateMessage.deserialize(object: decode);
        break;
      case TonRequestMethod.tonMnemonicToPrivateKey:
        args = TonMnemonicToPrivateKeyMessage.deserialize(object: decode);
        break;
    }
    if (args is! TonNetworkRequestArgs<T, A>) {
      throw WalletExceptionConst.invalidArgruments(
          "${MessageArgsNetwork<T, A>}", "${args.runtimeType}");
    }
    return args;
  }
}

class TonMnemonicToPrivateKeyMessage
    implements TonNetworkRequestArgs<ImportCustomKeys, MessageArgsOneBytes> {
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
        tags: TonRequestMethod.tonMnemonicToPrivateKey.tag);
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
        request.tag);
  }

  @override
  TonRequestMethod get request => TonRequestMethod.tonMnemonicToPrivateKey;

  @override
  MessageArgsOneBytes getResult() {
    final key = TonUtils.generateTonPrivateKeyFromSeed(
        mnemonic: mnemonic,
        password: password,
        validateTonMnemonic: validateTonMnemonic);
    final importedKey = ImportCustomKeys(
        privateKey: key.toHex(),
        publicKey: key.toPublicKey().toHex(),
        coin: coin);
    return MessageArgsOneBytes(keyOne: importedKey.toCbor().encode());
  }

  @override
  ImportCustomKeys parsResult(MessageArgsOneBytes result) {
    return ImportCustomKeys.deserialize(bytes: result.keyOne);
  }
}

class TonMenmonicGenerateMessage
    implements TonNetworkRequestArgs<String, MessageArgsOneBytes> {
  final String? password;
  final int wordsNum;
  const TonMenmonicGenerateMessage(
      {required this.password, required this.wordsNum});
  factory TonMenmonicGenerateMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: TonRequestMethod.generateMnemonic.tag);
    return TonMenmonicGenerateMessage(
        password: values.elementAt(0), wordsNum: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [password ?? const CborNullValue(), wordsNum]),
        request.tag);
  }

  @override
  TonRequestMethod get request => TonRequestMethod.generateMnemonic;

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
}
