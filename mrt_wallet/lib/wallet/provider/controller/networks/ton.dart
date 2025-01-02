part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin Web3TonImpl on WalletManager {
  Future<dynamic> _getWalletOwnerResult(Web3Request request);
  Future<dynamic> _getTonWeb3Result(Web3TonRequest request) async {
    switch (request.params.method) {
      default:
        return await _getWalletOwnerResult(request);
    }
  }
}
