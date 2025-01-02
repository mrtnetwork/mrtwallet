import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class NoneEncryptedRequestFakeMoneroTx
    extends NoneEncryptedCryptoRequest<BigInt, MessageArgsOneBytes> {
  final List<MoneroTxDestination> destinations;
  final BigInt fee;
  final MoneroTxDestination? change;
  final List<MoneroUnLockedPayment> fakePayments;
  NoneEncryptedRequestFakeMoneroTx(
      {required List<MoneroTxDestination> destinations,
      required this.fee,
      required this.change,
      required List<MoneroUnLockedPayment> fakePayments})
      : destinations = destinations.immutable,
        fakePayments = fakePayments.immutable;
  factory NoneEncryptedRequestFakeMoneroTx.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.moneroFakeTx.tag);

    return NoneEncryptedRequestFakeMoneroTx(
        destinations: values
            .elementAsListOf<CborBytesValue>(0)
            .map((e) => MoneroTxDestination.deserialize(e.value))
            .toList(),
        fee: values.elementAs(1),
        change: values.elemetMybeAs<MoneroTxDestination, CborBytesValue>(
            2, (e) => MoneroTxDestination.deserialize(e.value)),
        fakePayments: values
            .elementAsListOf<CborBytesValue>(3)
            .map((e) => MoneroPayment.deserialize(e.value))
            .toList()
            .cast());
  }

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    final result = await this.result();
    return MessageArgsOneBytes(
        keyOne:
            BigintUtils.toBytes(result, length: BigintUtils.orderLen(result)));
  }

  @override
  BigInt parsResult(MessageArgsOneBytes result) {
    return BigintUtils.fromBytes(result.keyOne, sign: false);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              destinations.map((e) => CborBytesValue(e.serialize())).toList()),
          fee,
          change == null
              ? const CborNullValue()
              : CborBytesValue(change!.serialize()),
          CborListValue.fixedLength(fakePayments
              .map((e) => CborBytesValue(e.toVariantSerialize()))
              .toList()),
        ]),
        method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.moneroFakeTx;

  @override
  Future<BigInt> result({List<int>? encryptedPart}) async {
    final List<SpendablePayment<MoneroUnLockedPayment<MoneroUnlockedOutput>>>
        spendablePayment =
        MoneroTransactionHelper.generateFakePaymentOuts(payments: fakePayments);
    final MoneroRctTxBuilder tx = MoneroRctTxBuilder(
        account: MoneroAccountKeys(
            account: MoneroAccount.fromSeed(RCT.identity(clone: false)),
            network: MoneroNetwork.stagenet),
        destinations: destinations,
        sources: spendablePayment,
        fee: fee,
        fakeTx: true,
        change: change);
    return tx.weight();
  }
}
