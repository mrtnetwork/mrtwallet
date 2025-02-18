import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3EthereumImpl<RESPONSE,
        T extends Web3EthereumRequestParam<RESPONSE>> extends EthTransactionImpl
    with Web3RequestControllerState {
  Web3EthereumImpl({required super.walletProvider, required this.request})
      : super(account: request.chain);

  final Web3EthereumRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;
  @override
  IEthAddress get address => request.accountPermission()!;

  @override
  Web3Request get web3Request => request;
}
