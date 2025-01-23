part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin Web3TronImpl on WalletManager {
  Future<dynamic> _getWalletOwnerResult(Web3Request request);
  Future<dynamic> _getTronWeb3Result(Web3TronRequest request) async {
    switch (request.params.method) {
      case Web3TronRequestMethods.switchTronChain:
        final param =
            request.params.cast<Web3TronSwitchChain>().chainId.toInt();
        final network = _appChains
            .chains()
            .whereType<TronChain>()
            .firstWhereOrNull(
                (e) => e.network.tronNetworkType.genesisBlockNumber == param);
        if (network == null) {
          throw Web3TronExceptionConstant.tronNetworkDoesNotExist;
        }
        await _getWalletOwnerResult(request);
        final Web3TronChain? permission = request.currentPermission;
        permission?.setActiveChain(network.network);
        request.authenticated.updateChainAccount(permission!);
        return network.network.tronNetworkType.genesisBlockNumber.toRadix16;
      default:
        return await _getWalletOwnerResult(request);
    }
  }
}
