part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin Web3SubstrateImpl on WalletManager {
  Future<dynamic> _getWalletOwnerResult(Web3Request request);
  Future<dynamic> _getSubstrateWeb3Result(Web3SubstrateRequest request) async {
    switch (request.params.method) {
      default:
        return await _getWalletOwnerResult(request);
    }
  }
}
