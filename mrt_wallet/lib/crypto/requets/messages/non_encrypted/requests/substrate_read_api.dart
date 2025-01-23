import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/wallet/api/api.dart';

class NoneEncryptedRequestSubstrateGetAPI
    extends NoneEncryptedCryptoRequest<List<int>?, MessageArgsOneBytes> {
  final SubstrateAPIProvider provider;
  NoneEncryptedRequestSubstrateGetAPI(
    this.provider,
  );
  factory NoneEncryptedRequestSubstrateGetAPI.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.substrateReadApi.tag);

    return NoneEncryptedRequestSubstrateGetAPI(
        SubstrateAPIProvider.fromCborBytesOrObject(obj: values.getCborTag(0)));
  }

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    final result = await this.result(encryptedPart: encryptedPart);
    return MessageArgsOneBytes(keyOne: result ?? []);
  }

  @override
  List<int>? parsResult(MessageArgsOneBytes result) {
    if (result.keyOne.isEmpty) return null;
    return result.keyOne;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([provider.toCbor()]), method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.substrateReadApi;

  @override
  Future<List<int>?> result({List<int>? encryptedPart}) async {
    final client = APIUtils.buildsubstrateClient(
        provider: provider, network: null, isolate: APPIsolate.current);
    try {
      final metadata = await client.getLastestVersionedMetadata();
      return BytesUtils.tryFromHexString(metadata);
    } finally {
      client.dispose();
    }
  }
}
