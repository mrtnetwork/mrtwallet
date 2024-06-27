import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/solana/transaction/controller/imp/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/wallet/models/signing_request/signing_reguest.dart';
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
    final signersAddresses = transaction.message.accountKeys
        .sublist(0, transaction.message.header.numRequiredSignatures)
        .map((e) => e.address)
        .toList();
    final signerAccounts = account.addresses
        .where((element) =>
            signersAddresses.contains(element.networkAddress.address))
        .toList();

    if (signersAddresses.length != signerAccounts.length) {
      throw WalletException("required_signer_account_missing".tr);
    }
    final signedTr = await walletProvider.signTransaction(
        request: SolanaSigningRequest(
            network: network,
            addresses: signerAccounts,
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
    final result = await MethodUtils.call(() async {
      return await _buildAndSigneTransaction();
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButtom: true, backToIdle: false);
    } else {
      progressKey.success(
          progressWidget:
              SuccessTransactionTextView(network: network, txId: result.result),
          backToIdle: false);
    }
  }
}
