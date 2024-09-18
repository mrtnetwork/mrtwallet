import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/solana/transaction/controller/imp/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

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
    final signedTr = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: signerAccounts,
      sign: (generateSignature) async {
        final digest = List<int>.unmodifiable(transaction.serializeMessage());
        for (int i = 0; i < signerAccounts.length; i++) {
          final addr = signerAccounts.elementAt(i);
          final signier = addr.keyIndex as Bip32AddressIndex;
          final signRequest =
              GlobalSignRequest.solana(digest: digest, index: signier);
          final sss = await generateSignature(signRequest);
          transaction.addSignature(addr.networkAddress, sss.signature);
        }
        return transaction;
      },
    ));
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
          showBackButton: true, backToIdle: false);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
              network: network, txId: [result.result]),
          backToIdle: false);
    }
  }
}
