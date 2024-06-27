import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'transaction.dart';

mixin CosmosSignerImpl on CosmosTransactiomImpl {
  Future<String> _buildTransaction() async {
    final messages = validator.validator.messages(address.networkAddress);
    final txbody = TXBody(messages: messages, memo: memo);
    final authInfo = AuthInfo(signerInfos: [
      address.signerInfo.copyWith(sequence: ownerAccount.sequence)
    ], fee: fee!.copyWith(amount: isThorChain ? [] : null));
    final SignDoc signDoc = SignDoc(
        bodyBytes: txbody.toBuffer(),
        authInfoBytes: authInfo.toBuffer(),
        chainId: latestBlock.block!.header.chainId,
        accountNumber: ownerAccount.accountNumber);
    final List<String> signersAddr = messages
        .map((e) => e.signers)
        .expand((element) => element)
        .where((element) => element != null)
        .toList()
        .cast();

    final signers = account.addresses
        .where((element) => signersAddr.contains(element.address.toAddress))
        .toList();

    final signRequest = CosmosSigningRequest(
        addresses: signers, network: network, digest: signDoc.toBuffer());
    final signatures =
        await walletProvider.signTransaction(request: signRequest);
    if (signatures.hasError) {
      throw signatures.exception!;
    }
    final txRaw = TxRaw(
        bodyBytes: txbody.toBuffer(),
        authInfoBytes: authInfo.toBuffer(),
        signatures: signatures.result);
    return await apiProvider.broadcastTransaction(txRaw.toBuffer());
  }

  Future<void> buildTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      return await _buildTransaction();
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txId: result.result.toString(),
          ),
          backToIdle: false);
    }
  }
}
