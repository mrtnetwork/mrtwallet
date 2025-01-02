import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

enum WalletTransactionType {
  send(0),
  received(1);

  final int value;
  const WalletTransactionType(this.value);
  static WalletTransactionType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw WalletExceptionConst.dataVerificationFailed,
    );
  }
}

// typedef WALLETNETWORKTRANSACTION<NETWORKADDRESS> = ChainTransaction<
//     NETWORKADDRESS,
//     WalletTransactionAmount,
//     WalletTransactionInput<NETWORKADDRESS>,
//     WalletTransactionOutput<NETWORKADDRESS, WalletTransactionAmount>,
//     ChainStorageKey>;

abstract class WalletAccountTransactions<TRANSACTION extends WalletTransaction>
    with CborSerializable {
  List<TRANSACTION> _transactions;
  List<TRANSACTION> get transactions => _transactions;
  WalletAccountTransactions({required List<TRANSACTION> transactions})
      : _transactions = transactions.immutable;
  void addTx(TRANSACTION tx) {
    final txes = [..._transactions, tx];
    txes.sort((a, b) => b.time.compareTo(a.time));
    _transactions = txes.immutable;
  }

  void removeTx(TRANSACTION tx) {
    final txes = _transactions.clone();
    txes.remove(tx);
    txes.sort((a, b) => a.time.compareTo(b.time));
    _transactions = txes.immutable;
  }
}

abstract class WalletTransaction<NETWORKADDRESS> {
  abstract final WalletTransactionType type;
  abstract final String txId;
  abstract final DateTime time;
  abstract final IntegerBalance totalOutput;
}

abstract class ChainTransaction<
        NETWORKADDRESS,
        AMOUNT extends WalletTransactionAmount,
        INPUTS extends WalletTransactionInput<NETWORKADDRESS>,
        OUTPUTS extends WalletTransactionOutput<NETWORKADDRESS, AMOUNT>,
        STORAGEKEY extends ChainStorageKey>
    with CborSerializable
    implements WalletTransaction<NETWORKADDRESS> {
  @override
  final WalletTransactionType type;
  @override
  final String txId;
  @override
  final DateTime time;
  @override
  final IntegerBalance totalOutput;
  final List<INPUTS> inputs;
  final List<OUTPUTS> outputs;

  ChainTransaction(
      {required this.txId,
      required this.time,
      required this.totalOutput,
      required List<INPUTS> inputs,
      required List<OUTPUTS> outputs,
      this.type = WalletTransactionType.send})
      : inputs = inputs.immutable,
        outputs = outputs.immutable;
}

abstract class WalletTransactionInput<NETWORKADDRESS> with CborSerializable {
  final NETWORKADDRESS from;

  const WalletTransactionInput({required this.from});
}

abstract class WalletTransactionOutput<NETWORKADDRESS,
    AMOUNT extends WalletTransactionAmount> with CborSerializable {
  final NETWORKADDRESS to;
  final AMOUNT amount;
  String get address;
  const WalletTransactionOutput({required this.to, required this.amount});
}

abstract class WalletTransactionAmount with CborSerializable {
  final IntegerBalance amount;
  final Token? token;
  const WalletTransactionAmount({required this.amount, this.token});
}
