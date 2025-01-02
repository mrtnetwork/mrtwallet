import 'package:blockchain_utils/bip/ecc/keys/ed25519_monero_keys.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/transaction/core/transaction.dart';

class MoneroAccountTransactions
    extends WalletAccountTransactions<MoneroWalletTransaction> {
  MoneroAccountTransactions({required super.transactions});

  factory MoneroAccountTransactions.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: CborTagsConst.moneroAccountTransactions);
    return MoneroAccountTransactions(
        transactions: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroWalletTransaction.deserialize(object: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              transactions.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.moneroAccountTransactions);
  }
}

class MoneroWalletTransaction extends ChainTransaction<
    MoneroAddress,
    MoneroTransactionAmount,
    MoneroTransactionInput,
    MoneroTransactionOutput,
    MoneroChainStorage> {
  final List<MoneroPrivateKey> txKeys;
  MoneroWalletTransaction(
      {required super.txId,
      required super.time,
      required super.inputs,
      required super.outputs,
      required List<MoneroPrivateKey> txKeys,
      super.type = WalletTransactionType.send})
      : txKeys = txKeys.immutable,
        super(
            totalOutput: IntegerBalance(
                outputs.fold<BigInt>(
                    BigInt.zero, (p, c) => p + c.amount.amount.balance),
                MoneroConst.decimal,
                allowNegative: false,
                imutable: true));

  factory MoneroWalletTransaction.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: CborTagsConst.moneroWalletTransaction);
    return MoneroWalletTransaction(
      txId: values.elementAs(0),
      time: values.elementAs(1),
      inputs: values
          .elementAsListOf<CborTagValue>(2)
          .map((e) => MoneroTransactionInput.deserialize(object: e))
          .toList(),
      outputs: values
          .elementAsListOf<CborTagValue>(3)
          .map((e) => MoneroTransactionOutput.deserialize(object: e))
          .toList(),
      txKeys: values
          .elementAsListOf<CborBytesValue>(4)
          .map((e) => MoneroPrivateKey.fromBytes(e.value))
          .toList(),
      // type: WalletTransactionType.fromValue(values.elementAs(5)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          txId,
          time,
          CborListValue.fixedLength(inputs.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(outputs.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              txKeys.map((e) => CborBytesValue(e.key)).toList()),
          type.value
        ]),
        CborTagsConst.moneroWalletTransaction);
  }
}

class MoneroTransactionAmount extends WalletTransactionAmount {
  MoneroTransactionAmount({required BigInt amount, super.token})
      : super(
            amount: IntegerBalance(amount, MoneroConst.decimal,
                allowNegative: false, imutable: true));
  factory MoneroTransactionAmount.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: CborTagsConst.moneroWalletTransactionAmount);
    return MoneroTransactionAmount(amount: values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([amount.balance]),
        CborTagsConst.moneroWalletTransactionAmount);
  }
}

class MoneroTransactionInput extends WalletTransactionInput<MoneroAddress> {
  MoneroTransactionInput({required super.from});
  factory MoneroTransactionInput.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: CborTagsConst.moneroWalletTransactionInput);
    return MoneroTransactionInput(from: MoneroAddress(values.elementAs(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([from.address]),
        CborTagsConst.moneroWalletTransactionInput);
  }
}

class MoneroTransactionOutput
    extends WalletTransactionOutput<MoneroAddress, MoneroTransactionAmount> {
  MoneroTransactionOutput(
      {required super.amount, required super.to, required this.proof});
  final String? proof;

  @override
  String get address => to.address;

  factory MoneroTransactionOutput.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: CborTagsConst.moneroWalletTransactionOutput);
    return MoneroTransactionOutput(
        amount:
            MoneroTransactionAmount.deserialize(object: values.getCborTag(0)),
        to: MoneroAddress(values.elementAs(1)),
        proof: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([amount.toCbor(), to.address, proof]),
        CborTagsConst.moneroWalletTransactionOutput);
  }
}
