import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/signing_reguest.dart';
import 'package:on_chain/ada/ada.dart';

import 'transaction.dart';

mixin CardanoSignerImpl on CardanoTransactionImpl {
  Future<ADATransaction> _sendTransaction() async {
    TransactionOutput? output;
    if (remindAmount.largerThanZero) {
      output = changeADAOutput.toOutput();
      output = output.copyWith(
          amount: output.amount.copyWith(coin: remindAmount.balance));
    }
    TransactionOutput? assetOutput;
    if (changeAssetOutput.hasAssets) {
      assetOutput = changeAssetOutput.toOutput();
    }

    final builder = ADATransactionBuilder(
        outputs: [
          ...receivers.map((e) => e.toOutput()).toList(),
          if (output != null) output,
          if (assetOutput != null) assetOutput
        ],
        utxos: selectedUtxos.map((e) => e.utxo.toUtxoResponse()).toList(),
        metadata: transactionMemo);
    builder.setFee(transactionFee.balance);
    final signerAddrs =
        selectedUtxos.map((e) => e.utxo.address).toList().toSet();
    final signers = addresses
        .where(
            (element) => signerAddrs.contains(element.networkAddress.address))
        .toList();

    final tr = await walletProvider.signCardanoTransaction(
        request: CardanoSigningRequest(
            addresses: signers, network: network, transaction: builder));
    if (tr.hasError) {
      throw tr.exception!;
    }
    return tr.result;
  }

  void sendTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodCaller.call(() async {
      final result = await _sendTransaction();
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
