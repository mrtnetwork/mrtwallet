import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/networks/secp256k1/signing_request.dart';
import 'package:on_chain/on_chain.dart';

mixin ETHSignerImpl on EthTransactionImpl {
  Future<void> signAndSendTransaction(ETHTransaction transaction) async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodCaller.call(() async {
      final nonce = await apiProvider.getAccountNonce(address.networkAddress);
      final tr = transaction.copyWith(nonce: nonce);
      final Secp256k1SigningRequest<ETHSignature> request =
          Secp256k1SigningRequest<ETHSignature>(
              address: address,
              network: network,
              transactionDigest: tr.serialized);
      final signature = await walletProvider.signTransaction(request: request);
      if (signature.hasError) {
        throw signature.exception!;
      }
      final signedSerialized = BytesUtils.toHexString(
          tr.signedSerialized(signature.result),
          prefix: "0x");
      final send = await apiProvider.sendRawTransaction(signedSerialized);
      return send;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      stopGasEstimate();
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txId: result.result,
          ),
          backToIdle: false);
    }
  }
}
