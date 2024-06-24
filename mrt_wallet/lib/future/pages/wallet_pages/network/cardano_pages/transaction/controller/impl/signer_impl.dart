import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/signing_reguest.dart';
import 'package:on_chain/ada/ada.dart';

import 'transaction.dart';

mixin CardanoSignerImpl on CardanoTransactionImpl {
  Future<ADATransaction> _signTransaction() async {
    try {
      final builder = buildTransaction(transactionFee.balance);
      final signers = getTransactionSignerAccounts();
      final signerKeyIndexes = getTransactionSignersKeysIndex();
      final tr = await walletProvider.signTransaction(
          request: CardanoSigningRequest(
              addresses: signers,
              network: network,
              transaction: builder,
              signers: signerKeyIndexes));
      if (tr.hasError) {
        throw tr.exception!;
      }
      return tr.result;
    } catch (e) {
      rethrow;
    }
  }

  void buildAndBroadcastTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodCaller.call(() async {
      final result = await _signTransaction();
      final ser = result.serialize();
      final broadcast = await providers.broadcastTransaction(ser);
      return broadcast;
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButtom: true);
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
