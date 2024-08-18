import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/access/key_response.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WalletRequestReadPrivateKeys
    implements WalletRequest<List<CryptoPrivateKeyData>, MessageArgsOneBytes> {
  final AccessCryptoPrivateKeysRequest request;
  WalletRequestReadPrivateKeys(this.request);

  factory WalletRequestReadPrivateKeys.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.readPrivateKeys.tag);
    return WalletRequestReadPrivateKeys(
        AccessCryptoPrivateKeysRequest.fromCborBytesOrObject(
            obj: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([request.toCbor()]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.readPrivateKeys;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final keys = wallet.readKeys(request.indexes);
    final response = CryptoPrivateKeysResponse(keys);
    return MessageArgsOneBytes(keyOne: response.toCbor().encode());
  }

  @override
  List<CryptoPrivateKeyData> parsResult(MessageArgsOneBytes result) {
    final response =
        CryptoPrivateKeysResponse.fromCborBytesOrObject(bytes: result.keyOne);
    return response.keys;
  }

  @override
  List<CryptoPrivateKeyData> result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final keys = wallet.readKeys(request.indexes);
    return keys;
  }
}
