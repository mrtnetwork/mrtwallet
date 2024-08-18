import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WalletRequestEthereumPersonalSign
    implements WalletRequest<String, MessageArgsOneBytes> {
  final List<int> message;
  final Bip32AddressIndex index;
  final int? payloadLength;
  WalletRequestEthereumPersonalSign({
    required List<int> message,
    required this.index,
    this.payloadLength,
  }) : message = BytesUtils.toBytes(message, unmodifiable: true);

  factory WalletRequestEthereumPersonalSign.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.ethereumPersonalSign.tag);
    return WalletRequestEthereumPersonalSign(
        message: values.elementAt(0),
        index:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(1)),
        payloadLength: values.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(message), index.toCbor(), payloadLength]),
        method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.ethereumPersonalSign;
  static List<int> sign(
      {required WalletMasterKeys wallet,
      required Bip32AddressIndex index,
      required List<int> message,
      int? payloadLength}) {
    final responseKeys =
        wallet.readKeys([AccessCryptoPrivateKeyRequest(index: index)]).first;
    final signer = ETHSigner.fromKeyBytes(responseKeys.privateKeyBytes());
    final signature =
        signer.signProsonalMessage(message, payloadLength: payloadLength);
    return signature;
  }

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final signature = sign(wallet: wallet, index: index, message: message);
    return MessageArgsOneBytes(keyOne: signature);
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return BytesUtils.toHexString(result.keyOne, prefix: "0x");
  }

  @override
  String result({required WalletMasterKeys wallet, required List<int> key}) {
    final signature = sign(wallet: wallet, index: index, message: message);
    return BytesUtils.toHexString(signature, prefix: "0x");
  }
}
