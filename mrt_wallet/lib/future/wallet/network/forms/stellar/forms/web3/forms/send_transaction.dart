import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/stellar/forms/core/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/models/transaction.dart';

class Web3StellarSendTransactionForm
    extends StellarWeb3Form<Web3StellarSendTransaction> {
  Web3StellarSendTransactionForm(this.request);
  @override
  @override
  Web3StellarRequest<String, Web3StellarSendTransaction> request;

  @override
  OnChangeForm? onChanged;
}
