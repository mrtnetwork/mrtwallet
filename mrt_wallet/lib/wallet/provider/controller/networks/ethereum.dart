part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin Web3EthereumImpl on WalletManager {
  _getWalletOwnerResult(Web3Request request);
  Future<dynamic> _getEthereumWeb3Result(Web3EthereumRequest request) async {
    switch (request.params.method) {
      case Web3EthereumRequestMethods.switchEthereumChain:
        final param = request.params.cast<Web3EthreumSwitchChain>().chainId;
        final network = _appChains
            .chains()
            .whereType<EthereumChain>()
            .firstWhereOrNull((e) => e.chainId == param);
        if (network == null) {
          throw Web3RequestExceptionConst.ethereumNetworkDoesNotExist;
        }
        await _getWalletOwnerResult(request);
        Web3EthereumChain? permission = request.currentPermission;
        permission?.setActiveChain(network);
        request.authenticated.updateChainAccount(permission!);
        return network.chainId.toRadix16;
      default:
        return await _getWalletOwnerResult(request);
    }
  }
}
