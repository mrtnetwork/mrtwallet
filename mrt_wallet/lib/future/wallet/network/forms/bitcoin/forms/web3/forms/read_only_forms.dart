import 'package:mrt_wallet/future/wallet/network/forms/bitcoin/forms/core/bitcoin.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/params/core/request.dart';

class Web3BitcoinReadOnlyForm<PARAMS extends Web3BitcoinRequestParam>
    extends BitcoinWeb3Form<PARAMS> {
  Web3BitcoinReadOnlyForm({required this.request});

  @override
  Web3BitcoinRequest<dynamic, PARAMS> request;
}
