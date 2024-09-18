import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/personal_sign_response.dart';

class WalletRequestSignMessage
    implements WalletRequest<CryptoPersonalSignResponse, MessageArgsOneBytes> {
  final List<int> message;
  final Bip32AddressIndex index;
  final int? payloadLength;
  final NetworkType network;
  WalletRequestSignMessage({
    required List<int> message,
    required this.index,
    this.network = NetworkType.ethereum,
    this.payloadLength,
  }) : message = BytesUtils.toBytes(message, unmodifiable: true);

  factory WalletRequestSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.signMessage.tag);
    return WalletRequestSignMessage(
        message: values.elementAt(0),
        index:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(1)),
        payloadLength: values.elementAt(2),
        network: NetworkType.fromTag(values.elementAt(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(message),
          index.toCbor(),
          payloadLength,
          network.tag
        ]),
        method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.signMessage;
  static List<int> sign(
      {required WalletMasterKeys wallet,
      required Bip32AddressIndex index,
      required List<int> message,
      required NetworkType network,
      int? payloadLength}) {
    switch (network) {
      case NetworkType.ethereum:
        final responseKeys = wallet
            .readKeys([AccessCryptoPrivateKeyRequest(index: index)]).first;
        final signer = ETHSigner.fromKeyBytes(responseKeys.privateKeyBytes());
        return signer.signProsonalMessage(message,
            payloadLength: payloadLength);
      case NetworkType.tron:
        final responseKeys = wallet
            .readKeys([AccessCryptoPrivateKeyRequest(index: index)]).first;
        final signer = TronSigner.fromKeyBytes(responseKeys.privateKeyBytes());
        return signer.signProsonalMessage(message,
            payloadLength: payloadLength);
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
  }

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final signature =
        sign(wallet: wallet, index: index, message: message, network: network);
    return MessageArgsOneBytes(keyOne: signature);
  }

  @override
  CryptoPersonalSignResponse parsResult(MessageArgsOneBytes result) {
    return CryptoPersonalSignResponse(
        signatureHex: BytesUtils.toHexString(result.keyOne, prefix: "0x"),
        signature: result.keyOne);
  }

  @override
  CryptoPersonalSignResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final signature =
        sign(wallet: wallet, index: index, message: message, network: network);
    return CryptoPersonalSignResponse(
        signatureHex: BytesUtils.toHexString(signature, prefix: "0x"),
        signature: signature);
  }
}
