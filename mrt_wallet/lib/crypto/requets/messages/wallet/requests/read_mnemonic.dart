import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/access/seed_response.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WalletRequestReadMnemonic
    implements WalletRequest<AccessMnemonicResponse, MessageArgsOneBytes> {
  WalletRequestReadMnemonic();

  factory WalletRequestReadMnemonic.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.readMnemonic.tag);
    return WalletRequestReadMnemonic();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.readMnemonic;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final response = AccessMnemonicResponse(wallet.mnemonic);
    return MessageArgsOneBytes(keyOne: response.toCbor().encode());
  }

  @override
  AccessMnemonicResponse parsResult(MessageArgsOneBytes result) {
    final response =
        AccessMnemonicResponse.fromCborBytesOrObject(bytes: result.keyOne);
    return response;
  }

  @override
  AccessMnemonicResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    return AccessMnemonicResponse(wallet.mnemonic);
  }
}
