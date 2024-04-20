import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/solana_pages/transaction/controller/imp/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/signing_reguest.dart';
import 'package:on_chain/solana/solana.dart';

mixin SolanaSignerImpl on SolanaTransactionImpl {
  Future<String> _buildAndSigneTransaction() async {
    final bl =
        await apiProvider.provider.request(const SolanaRPCGetLatestBlockhash());
    final transaction = SolanaTransaction(
        payerKey: owner.networkAddress,
        instructions: [
          ...(await validator.validator.instructions(owner.networkAddress)),
          if (memo != null) memo!,
        ],
        recentBlockhash: bl.blockhash);
    final signedTr = await walletProvider.signSolanaTransaction(
        request: SolanaSigningRequest(
            network: network,
            addresses: [owner],
            solanaTransaction: transaction));
    if (signedTr.hasError) {
      throw signedTr.exception!;
    }
    try {
      final provider = await apiProvider.provider.request(
          SolanaRPCSendTransaction(
              encodedTransaction: signedTr.result.serializeString()));
      return provider;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> buildAndSignTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodCaller.call(() async {
      return await _buildAndSigneTransaction();
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.success(
          progressWidget:
              SuccessTransactionTextView(network: network, txId: result.result),
          backToIdle: false);
    }
  }
}
