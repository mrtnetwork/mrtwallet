import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/personal_sign_response.dart';

class WalletRequestBitcoinSignMessage extends WalletRequest<
    CryptoBitcoinPersonalSignResponse, MessageArgsTwoBytes> {
  final List<int> message;
  final Bip32AddressIndex index;
  final String? messagePrefix;
  final BIP137Mode mode;
  WalletRequestBitcoinSignMessage({
    required List<int> message,
    required this.index,
    required this.messagePrefix,
    required this.mode,
  }) : message = message.asImmutableBytes;

  factory WalletRequestBitcoinSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.bitcoinSignMessage.tag);
    return WalletRequestBitcoinSignMessage(
        message: values.elementAt(0),
        index:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(1)),
        messagePrefix: values.elementAt(2),
        mode: BIP137Mode.fromValue(values.elementAt(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(message),
          index.toCbor(),
          messagePrefix,
          mode.header
        ]),
        method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.bitcoinSignMessage;
  static MessageArgsTwoBytes sign(
      {required WalletMasterKeys wallet,
      required Bip32AddressIndex index,
      required List<int> message,
      required BIP137Mode mode,
      String? messagePrefix}) {
    final responseKeys =
        wallet.readKeys([AccessCryptoPrivateKeyRequest(index: index)]).first;
    final signer =
        BitcoinKeySigner.fromKeyBytes(responseKeys.privateKeyBytes());
    final digest = QuickCrypto.sha256Hash(BitcoinSignerUtils.magicMessage(
            message, messagePrefix ?? BitcoinSignerUtils.signMessagePrefix))
        .asImmutableBytes;
    final signature = signer.signMessage(
        message: digest,
        hashMessage: false,
        messagePrefix: messagePrefix ?? BitcoinSignerUtils.signMessagePrefix);
    int rId = signature[0] + mode.header;
    return MessageArgsTwoBytes(
        keyOne: [rId, ...signature.sublist(1)], keyTwo: digest);
  }

  @override
  MessageArgsTwoBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    return sign(
        wallet: wallet,
        index: index,
        message: message,
        mode: mode,
        messagePrefix: messagePrefix);
  }

  @override
  CryptoBitcoinPersonalSignResponse parsResult(MessageArgsTwoBytes result) {
    return CryptoBitcoinPersonalSignResponse(
        signatureBase64:
            StringUtils.decode(result.keyOne, type: StringEncoding.base64),
        digest: result.keyTwo);
  }

  @override
  CryptoBitcoinPersonalSignResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final signature = sign(
        wallet: wallet,
        index: index,
        message: message,
        mode: mode,
        messagePrefix: messagePrefix);
    return CryptoBitcoinPersonalSignResponse(
        signatureBase64:
            StringUtils.decode(signature.keyOne, type: StringEncoding.base64),
        digest: signature.keyTwo);
  }
}
