import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain/solidity/abi/abi.dart';

class WalletRequestEthereumTypedDataSign
    implements WalletRequest<String, MessageArgsOneBytes> {
  final EIP712Base message;
  final Bip32AddressIndex index;
  WalletRequestEthereumTypedDataSign(
      {required this.message, required this.index});

  factory WalletRequestEthereumTypedDataSign.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.ethereumTypedDataSign.tag);
    return WalletRequestEthereumTypedDataSign(
        message: EIP712Base.fromJson(StringUtils.toJson(values.elementAt(0))),
        index:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [StringUtils.fromJson(message.toJson()), index.toCbor()]),
        method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.ethereumTypedDataSign;

  static List<int> sign(
      {required WalletMasterKeys wallet,
      required Bip32AddressIndex index,
      required EIP712Base message,
      int? payloadLength}) {
    final responseKeys =
        wallet.readKeys([AccessCryptoPrivateKeyRequest(index: index)]).first;
    final signer = ETHSigner.fromKeyBytes(responseKeys.privateKeyBytes());
    final sign = signer.sign(message.encode(hash: false));
    return sign.toBytes();
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
