import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/tron.dart';

import 'package:mrt_wallet/wallet/web3/networks/tron/params/params.dart';
import 'package:on_chain/tron/tron.dart';

class TronWeb3TransactionForm implements TronWeb3Form<Web3TronSendTransaction> {
  TronWeb3TransactionForm(
      {required this.request, required this.transactionInfo});
  @override
  OnChangeForm? onChanged;
  @override
  ObjectVoid? onCompeleteForm;
  @override
  DynamicVoid? onStimateChanged;

  @override
  void confirmRequest({Object? response}) {}
  Transaction get transaction => request.params.transaction;
  late final TronBaseContract contract = transaction.rawData.getContract();

  @override
  String get name => request.params.method.name;

  @override
  final Web3TronRequest<Map<String, dynamic>, Web3TronSendTransaction> request;
  final Web3TronTransactionInfo transactionInfo;
  late final TransactionContractType type =
      request.params.transaction.rawData.type;
}
