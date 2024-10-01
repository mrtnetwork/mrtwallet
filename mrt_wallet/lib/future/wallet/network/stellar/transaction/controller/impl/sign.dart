import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/messages.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';

mixin StellarTransactionSignerImpl on StellarTransactionImpl {
  StellarTransactionV1 _createTransaction() {
    final cloneOperations = customOperations.clone();
    cloneOperations.sort((a, b) {
      if (a.type == OperationType.createAccount) {
        return -1;
      } else if (b.type == OperationType.createAccount) {
        return 1;
      }
      return 0;
    });
    final transaction = StellarTransactionV1(
        sourceAccount: address.networkAddress.toMuxedAccount(),
        fee: fee!.balance.toInt(),
        seqNum: accountInfo.sequence + BigInt.one,
        cond: timebound.condition(),
        operations: cloneOperations.map((e) => e.toOperation()).toList(),
        memo: memo?.memo ?? const StellarMemoNone());
    return transaction;
  }

  Future<TransactionV1Envelope> _signTransaction() async {
    final transaction = _createTransaction();
    final payload = TransactionSignaturePayload(
        taggedTransaction: transaction,
        networkId: network.coinParam.passphraseHash());

    final List<int> digest = payload.txHash().asImmutableBytes;
    final request = WalletSigningRequest(
        addresses: [address],
        network: network,
        sign: (sign) async {
          final request = GlobalSignRequest.stellar(
              digest: digest, index: address.keyIndex.cast());
          final signature = await sign(request);
          final signerPubkey = signature.signerPubKey.keyBytes();
          final keyHint = signerPubkey.sublist(
              signerPubkey.length - StellarConst.stellarPubkeyHintLength);
          return [
            DecoratedSignature(hint: keyHint, signature: signature.signature)
          ];
        });
    final result =
        await walletProvider.wallet.signTransaction(request: request);
    return TransactionV1Envelope(tx: transaction, signatures: result.result);
  }

  Future<void> signAndSendTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async => await _signTransaction());
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
      return;
    }
    final envelopeXdr = result.result.toVariantXDRBase64();
    final submissionResult = await MethodUtils.call(
        () async => await apiProvider.submitTx(envelopeXdr));
    if (submissionResult.hasError) {
      progressKey.errorText(submissionResult.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    if (submissionResult.result.successful) {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txId: [submissionResult.result.id],
          ),
          backToIdle: false);
    } else {
      final result = MethodUtils.nullOnException(
          () => submissionResult.result.getResult().toJson());
      if (result == null) {
        progressKey.errorText("submit_transaction_error".tr.replaceOne(''),
            backToIdle: false, showBackButton: true);
      } else {
        progressKey.errorText(
            "submit_transaction_error"
                .tr
                .replaceOne("\n${StringUtils.fromJson(result)}"),
            backToIdle: false,
            showBackButton: true);
      }
    }
  }
}
