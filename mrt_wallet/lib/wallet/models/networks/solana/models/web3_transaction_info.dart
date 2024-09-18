import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/networks/solana.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain/solana/src/borsh_serialization/program_layout.dart';

class SolanaWeb3TransactionInstructionInfo {
  final ProgramLayout layout;
  final List<SolanaAccountStatus> accounts;
  final SolAddress programAddress;
  final Map<String, dynamic>? content;

  SolanaWeb3TransactionInstructionInfo(
      {required this.layout,
      required this.programAddress,
      required List<SolanaAccountStatus> accounts,
      Map<String, dynamic>? content})
      : content = content?.imutable,
        accounts = accounts.imutable;
}

class SolanaAccountStatus {
  final AccountMeta account;
  final List<String> status;
  SolanaAccountStatus._({required this.account, required List<String> status})
      : status = status.imutable;
  factory SolanaAccountStatus(AccountMeta account) {
    List<String> status = [];
    if (account.isSigner) {
      status.add("signer");
    }
    if (account.isWritable) {
      status.add("writable");
    }
    if (status.isEmpty) {
      status.add("read_only");
    }
    return SolanaAccountStatus._(account: account, status: status);
  }
}

class SolanaWeb3TransactionInfo {
  SolanaTransaction _transaction;
  SolanaTransaction get transaction => _transaction;
  final IntegerBalance accountChange;
  final SolAddress feePayer;
  final ISolanaAddress signer;
  final List<SolanaWeb3TransactionInstructionInfo> instructions;
  final int id;
  SolanaWeb3SimulationStatus _status = SolanaWeb3SimulationStatus.idle;
  SolanaWeb3SimulationStatus get status => _status;
  SolanaWeb3FeeStatus _feeStatus = SolanaWeb3FeeStatus.idle;
  SolanaWeb3FeeStatus get feeStatus => _feeStatus;
  late final SimulateTranasctionResponse _simulate;
  SimulateTranasctionResponse get simulateInfo => _simulate;
  bool get canUpdateBlockHash => _transaction.signers.length == 1;

  final IntegerBalance fee = IntegerBalance.zero(SolanaConst.decimal);

  void setFeeErr() {
    _feeStatus = SolanaWeb3FeeStatus.error;
  }

  void setFeePending() {
    _feeStatus = SolanaWeb3FeeStatus.pending;
  }

  void setFee(BigInt? fee) {
    if (this.fee.isZero) {
      this.fee.updateBalance(fee);
    }
    if (this.fee.isZero) {
      setFeeErr();
    } else {
      _feeStatus = SolanaWeb3FeeStatus.success;
    }
  }

  void setSimulateErr() {
    _status = SolanaWeb3SimulationStatus.error;
  }

  void setSimulatePending() {
    _status = SolanaWeb3SimulationStatus.pending;
  }

  void setSimulateSuccess(SimulateTranasctionResponse simulate) {
    if (status == SolanaWeb3SimulationStatus.success ||
        status == SolanaWeb3SimulationStatus.simulateError) return;
    _simulate = simulate;
    if (_simulate.err != null) {
      _status = SolanaWeb3SimulationStatus.simulateError;
    } else {
      _status = SolanaWeb3SimulationStatus.success;
    }
  }

  void updateTransaction(SolanaTransaction transaction) {
    if (transaction.signers.length != 1) return;
    final signer = transaction.signers[0];
    if (this.signer.networkAddress != signer) return;
    if (!CompareUtils.iterableIsEqual(transaction.message.compiledInstructions,
        this.transaction.message.compiledInstructions)) {
      return;
    }
    _transaction = transaction;
  }

  SolanaWeb3TransactionInfo._({
    required SolanaTransaction transaction,
    required this.accountChange,
    required this.feePayer,
    required List<SolanaWeb3TransactionInstructionInfo> instructions,
    required this.signer,
    required this.id,
  })  : instructions = instructions.imutable,
        _transaction = transaction;
  factory SolanaWeb3TransactionInfo(
      {required SolanaTransaction transaction,
      required ISolanaAddress signer,
      required int id}) {
    final accounts = transaction.message.accountKeys;
    List<SolanaWeb3TransactionInstructionInfo> instructions = [];
    for (final i in transaction.message.compiledInstructions) {
      final programId = accounts[i.programIdIndex];
      final layout = ProgramLayout.fromBytes(
          programId: programId, instructionBytes: i.data);
      final content = layout.toJson();
      final accountKeys = List.generate(i.accounts.length, (e) {
        final int index = i.accounts[e];
        final account = transaction.message.accountKeys.elementAt(index);
        final isWritable = transaction.message.isAccountWritable(index);
        final isSigner = transaction.message.isAccountSigner(index);
        return SolanaAccountStatus(AccountMeta(
            publicKey: account, isSigner: isSigner, isWritable: isWritable));
      });
      final instructionInfo = SolanaWeb3TransactionInstructionInfo(
          layout: layout,
          programAddress: programId,
          content: content.isEmpty ? null : content,
          accounts: accountKeys);
      instructions.add(instructionInfo);
    }
    return SolanaWeb3TransactionInfo._(
        transaction: transaction,
        accountChange: IntegerBalance.zero(SolanaUtils.decimal),
        feePayer: accounts[0],
        instructions: instructions,
        signer: signer,
        id: id);
  }
}

class SolanaWeb3SignedTransactionInfo {
  final SolanaWeb3TransactionInfo info;
  final List<int> signature;
  SolanaWeb3SignedTransactionInfo(
      {required this.info, required List<int> signature})
      : signature = BytesUtils.toBytes(signature, unmodifiable: true);
}

enum SolanaWeb3SimulationStatus {
  error,
  simulateError,
  success,
  pending,
  idle;

  bool get canRetry => this == idle || this == error;
  bool get isError => this == error;
  bool get isSuccess => this == success;
  bool get isPending => this == pending;
  bool get hasSimulateError => this == error || this == simulateError;
}

enum SolanaWeb3FeeStatus {
  error,
  success,
  pending,
  idle;

  bool get canRetry => this == idle || this == error;
  bool get isError => this == error;
  bool get isPending => this == pending;
}
