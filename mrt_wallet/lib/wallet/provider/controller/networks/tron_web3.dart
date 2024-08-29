part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin Web3TronImpl on WalletManager {
  _getWalletOwnerResult(Web3Request request);
  Future<dynamic> _getTronWeb3Result(Web3TronRequest request) async {
    switch (request.params.method) {
      default:
        return await _getWalletOwnerResult(request);
    }
  }
}
