import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/api/client/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/constant/networks/solana.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/networks/solana/models/web3_transaction_info.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:on_chain/solana/src/transaction/transaction/transaction.dart';

class Web3SolanaSendTransactionForm
    extends SolanaWeb3Form<Web3SolanaSendTransaction> {
  @override
  OnChangeForm? onChanged;

  Web3SolanaSendTransactionForm({required this.request});
  List<SolanaWeb3TransactionInfo> _transactions = [];
  List<SolanaWeb3TransactionInfo> get transaction => _transactions;
  late SolanaClient _client;
  final IntegerBalance fee = IntegerBalance.zero(SolanaConst.decimal);

  Future<void> simulate(SolanaWeb3TransactionInfo transaction) async {
    if (transaction.status.canRetry) {
      transaction.setSimulatePending();
      onChanged?.call();
      final result = await MethodUtils.call(() async => await _client.simulate(
          transaction: transaction.transaction,
          account: transaction.signer.networkAddress));
      if (result.hasError) {
        transaction.setSimulateErr();
      } else {
        transaction.setSimulateSuccess(result.result);
        if (transaction.simulateInfo.accounts?.isNotEmpty ?? false) {
          transaction.accountChange
              .updateBalance(transaction.simulateInfo.accounts?[0]?.lamports);
        }
      }
    }
    onChanged?.call();
  }

  Future<void> getFee(SolanaWeb3TransactionInfo transaction) async {
    if (transaction.feeStatus.canRetry) {
      transaction.setFeePending();
      onChanged?.call();
      final result = await MethodUtils.call(
          () async => await _client.getFee(transaction.transaction));
      if (result.hasError) {
        transaction.setFeeErr();
      } else {
        transaction.setFee(result.result);
      }
    }
    final totalFee =
        _transactions.fold(BigInt.zero, (p, c) => p + c.fee.balance);
    fee.updateBalance(totalFee);
    onChanged?.call();
  }

  Future<void> replateBlockHash() async {
    SolAddress? blockHash;
    for (final i in transaction) {
      if (!i.canUpdateBlockHash) continue;
      blockHash ??= await _client.getBlockHash();
      final updateMessage =
          i.transaction.message.copyWith(recentBlockhash: blockHash);
      final newTransaction = SolanaTransaction.fromMessage(updateMessage);
      i.updateTransaction(newTransaction);
    }
  }

  void init(
      {required List<SolanaWeb3TransactionInfo> transactions,
      required SolanaClient client}) {
    _transactions = transactions;
    _client = client;
    for (final i in _transactions) {
      simulate(i);
      getFee(i);
    }
  }

  @override
  Web3SolanaRequest<List<Map<String, dynamic>>, Web3SolanaSendTransaction>
      request;
}
