import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';

mixin TronSignerImpl on TronTransactionImpl {
  Future<void> signAndSendTransaction(TronBaseContract transaction) async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      int? permissionId;
      if (address.multiSigAccount) {
        final multiSigAccount = address as ITronMultisigAddress;
        permissionId = multiSigAccount.multiSignatureAccount.permissionID;
      }

      final block = await apiProvider.getNowBlock();
      final BigInt expiration = BigInt.from(DateTime.now()
          .add(TronUtils.defaultTronTrasactionExpiration)
          .millisecondsSinceEpoch);

      final raw = TransactionRaw(
          refBlockBytes: block.blockHeader.rawData.refBlockBytes,
          refBlockHash: block.blockHeader.rawData.refBlockHash,
          expiration: expiration,
          feeLimit: field.type == TransactionContractType.triggerSmartContract
              ? consumedFee!.feeLimit.balance
              : null,
          data: StringUtils.tryToBytes(memo),
          contract: [
            TransactionContract(
                type: transaction.contractType,
                permissionId: permissionId,
                parameter:
                    Any(typeUrl: transaction.typeURL, value: transaction))
          ],
          timestamp: block.blockHeader.rawData.timestamp);

      final Secp256k1SigningRequest<List<List<int>>> request =
          Secp256k1SigningRequest<List<List<int>>>(
              address: address,
              network: network,
              transactionDigest: raw.toBuffer());
      final signature = await walletProvider.signTransaction(request: request);
      if (signature.hasError) {
        throw signature.exception!;
      }
      final tr = Transaction(rawData: raw, signature: signature.result);
      final result = await apiProvider.sendTransaction(tr.toHex);
      return result;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txId: result.result,
          ),
          backToIdle: false);
    }
  }
}
