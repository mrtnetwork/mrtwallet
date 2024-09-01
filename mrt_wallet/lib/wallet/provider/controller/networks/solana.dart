part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin Web3SolanaImpl on WalletManager {
  _getWalletOwnerResult(Web3Request request);
  Future<dynamic> _getSolanaWeb3Result(Web3SolanaRequest request) async {
    switch (request.params.method) {
      default:
        return await _getWalletOwnerResult(request);
    }
  }
}
