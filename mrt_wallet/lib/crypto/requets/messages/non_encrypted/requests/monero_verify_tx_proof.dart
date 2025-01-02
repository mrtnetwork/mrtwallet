import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/wallet/api/api.dart';

class NoneEncryptedRequestMoneroVerifyTxProof
    extends NoneEncryptedCryptoRequest<BigInt?, MessageArgsOneBytes> {
  final String txId;
  final MoneroAPIProvider provider;
  final String? message;
  final MoneroAddress address;
  final String signature;
  NoneEncryptedRequestMoneroVerifyTxProof(
      {required this.txId,
      required this.provider,
      required this.message,
      required this.address,
      required this.signature});
  factory NoneEncryptedRequestMoneroVerifyTxProof.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.moneroVerifyProof.tag);

    return NoneEncryptedRequestMoneroVerifyTxProof(
        txId: values.elementAs(0),
        provider:
            MoneroAPIProvider.fromCborBytesOrObject(obj: values.getCborTag(1)),
        message: values.elementAs(2),
        address: MoneroAddress(values.elementAs(3)),
        signature: values.elementAs(4));
  }

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    final result = await this.result(encryptedPart: encryptedPart);
    return MessageArgsOneBytes(
        keyOne: result == null
            ? []
            : BigintUtils.toBytes(result,
                length: BigintUtils.bitlengthInBytes(result)));
  }

  @override
  BigInt? parsResult(MessageArgsOneBytes result) {
    if (result.keyOne.isEmpty) return null;
    return BigintUtils.fromBytes(result.keyOne);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [txId, provider.toCbor(), message, address.address, signature]),
        method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.moneroVerifyProof;

  @override
  Future<BigInt?> result({List<int>? encryptedPart}) async {
    final client = APIUtils.buildMoneroClient(
        provider: provider, network: null, isolate: APPIsolate.current);
    try {
      final transaction = await client.getTx(txId);
      return MoneroTransactionHelper.checkProof(
          transaction: transaction,
          address: address,
          proofStr: signature,
          message: message);
    } finally {
      client.dispose();
    }
  }
}
