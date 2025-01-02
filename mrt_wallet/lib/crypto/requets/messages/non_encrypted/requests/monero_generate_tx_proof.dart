import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class NoneEncryptedRequestMoneroGenerateTxProof
    extends NoneEncryptedCryptoRequest<String, MessageArgsOneBytes> {
  final String txId;
  final MoneroAPIProvider provider;
  final String? message;
  // final MoneroAccountIndex index;
  NoneEncryptedRequestMoneroGenerateTxProof(
      {required this.txId, required this.provider, required this.message});
  factory NoneEncryptedRequestMoneroGenerateTxProof.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.moneroGenerateProof.tag);

    return NoneEncryptedRequestMoneroGenerateTxProof(
        txId: values.elementAs(0),
        provider:
            MoneroAPIProvider.fromCborBytesOrObject(obj: values.getCborTag(1)),
        message: values.elementAs(2));
  }

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    final result = await this.result(encryptedPart: encryptedPart);
    return MessageArgsOneBytes(keyOne: StringUtils.encode(result));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return StringUtils.decode(result.keyOne);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([txId, provider.toCbor(), message]),
        method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.moneroGenerateProof;

  @override
  Future<String> result({List<int>? encryptedPart}) async {
    final account = MoneroViewAccountDetails.deserialize(bytes: encryptedPart);
    final client = APIUtils.buildMoneroClient(
        provider: provider, network: null, isolate: APPIsolate.current);
    final transaction = await client.getTx(txId);
    final proof = MoneroTransactionHelper.generateInProof(
        transaction: transaction,
        account: account.viewKey.account,
        index: account.index,
        message: message);
    return proof.toBase58();
  }
}
