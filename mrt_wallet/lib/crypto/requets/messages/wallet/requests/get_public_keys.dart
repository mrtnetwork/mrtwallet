import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/access/key_response.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WalletRequestReadPublicKeys
    implements WalletRequest<List<CryptoPublicKeyData>, MessageArgsOneBytes> {
  final AccessCryptoPrivateKeysRequest request;
  WalletRequestReadPublicKeys(this.request);

  factory WalletRequestReadPublicKeys.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.readPublicKeys.tag);
    return WalletRequestReadPublicKeys(
        AccessCryptoPrivateKeysRequest.fromCborBytesOrObject(
            obj: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([request.toCbor()]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.readPublicKeys;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final keys = wallet.readPublicKeys(request.indexes);
    final response = CryptoPublicKeysResponse(keys);
    return MessageArgsOneBytes(keyOne: response.toCbor().encode());
  }

  @override
  List<CryptoPublicKeyData> parsResult(MessageArgsOneBytes result) {
    final response =
        CryptoPublicKeysResponse.fromCborBytesOrObject(bytes: result.keyOne);
    return response.keys;
  }

  @override
  List<CryptoPublicKeyData> result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final keys = wallet.readPublicKeys(request.indexes);
    return keys;
  }
}
