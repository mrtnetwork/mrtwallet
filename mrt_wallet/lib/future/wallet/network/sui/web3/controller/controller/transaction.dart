import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/sui/sui.dart';
import 'package:mrt_wallet/future/wallet/network/sui/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/sui/src/keypair/types/types.dart';
import 'package:on_chain/sui/src/keypair/utils/utils.dart';
import 'package:on_chain/sui/src/transaction/types/types.dart';

class Web3SuiTransactionRequestController
    extends Web3SuiImpl<Map<String, dynamic>, Web3SuiSignOrExecuteTransaction> {
  late final LiveTransactionForm<Web3SuiSendTransactionForm> liveRequest =
      LiveTransactionForm(
          validator: Web3SuiSendTransactionForm(request: request));
  Web3SuiSendTransactionForm get form => liveRequest.validator;
  bool get isExecute => request.params.isExecute;
  final Cancelable _cancelable = Cancelable();

  Web3SuiTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  Future<Web3SuiSignTransactionResponse> _createTransaction(
      SuiTransactionDataV1 transaction) async {
    if (transaction.gasData.payment.isEmpty) {
      transaction = await apiProvider.filledGasPayment(transaction);
    }

    final transactionDigest = SuiCryptoUtils.generateTransactionDigest(
        txBytes: transaction.serializeSign(), hashDigest: true);
    final signatures = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: [address],
      sign: (generateSignature) async {
        if (address.multiSigAccount) {
          final multisigAccount = address as ISuiMultiSigAddress;
          List<SuiGenericSignature> signatures = [];
          int weight = 0;
          for (final i in multisigAccount.multiSignatureAddress.publicKeys) {
            final Bip32AddressIndex signer = i.keyIndex;
            final signRequest =
                GlobalSignRequest.sui(digest: transactionDigest, index: signer);
            final signature = await generateSignature(signRequest);
            signatures.add(SuiGenericSignature(
                signature: signature.signature,
                algorithm: i.keyScheme.suiKeyAlgorithm));
            weight += i.weight;
            if (weight >= multisigAccount.multiSignatureAddress.threshold) {
              break;
            }
          }
          if (weight < multisigAccount.multiSignatureAddress.threshold) {
            throw WalletException("insufficient_signatures");
          }
          return signatures;
        } else {
          final Bip32AddressIndex signer = address.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.sui(digest: transactionDigest, index: signer);
          final signature = await generateSignature(signRequest);
          final suiSignature = SuiGenericSignature(
              signature: signature.signature,
              algorithm: address.keyScheme.suiKeyAlgorithm);
          return [suiSignature];
        }
      },
    ));

    final signature = address.createTransactionAuthenticated(signatures.result);
    return Web3SuiSignTransactionResponse(
        bytes: transaction.toVariantBcsBase64(),
        signature: signature.toVariantBcsBase64(),
        digest: transaction.txHash());
  }

  Future<void> _onCompleteForm(Object? transaction) async {
    if (transaction is! SuiTransactionDataV1) return;
    if (isExecute) {
      progressKey.process(text: "signing_transaction_please_wait".tr);
    } else {
      progressKey.process(
          text: "create_send_transaction"
              .tr
              .replaceOne(network.coinParam.token.name));
    }
    final signedTransaction = await MethodUtils.call(
        () => _createTransaction(transaction),
        cancelable: _cancelable);
    if (signedTransaction.hasError) {
      progressKey.error(
          error: signedTransaction.exception, showBackButton: true);
      return;
    }
    _cancelable.dispose();
    if (isExecute) {
      final execute = await MethodUtils.call(
          () => apiProvider.executeWeb3Transaction(
              signatures: [signedTransaction.result.signature],
              transactionBcs: signedTransaction.result.bytes,
              options: request.params.executeOptions,
              type: request.params.executeType),
          cancelable: _cancelable);
      if (execute.hasError) {
        progressKey.error(error: execute.exception, showBackButton: true);
        return;
      }
      if (execute.result.error != null) {
        progressKey.errorResponse(message: execute.result.error);
        request.error(Web3RequestExceptionConst.excuteTransactionFailed(
            execute.result.error!));
        return;
      }
      final response = Web3SuiSignAndExecuteTransactionResponse(
          digest: signedTransaction.result.digest,
          effects: execute.result.rawTransactionData ?? '',
          excuteResponse: execute.result.effects);

      request.completeResponse(response.toJson());
      progressKey.responseTx(hash: response.digest, network: network);
    } else {
      request.completeResponse(signedTransaction.result.toJson());
      progressKey.response(text: "transaction_signed".tr);
    }
  }

  @override
  Future<void> initWeb3() async {
    liveRequest.addListener(_onChangeForm);
    form.onCompleteForm = _onCompleteForm;
    await walletProvider.wallet
        .updateAccountBalance(account, addresses: [address]);
    final init = await MethodUtils.call(
        () => form.initForm(account: account, address: address));
    if (init.hasError) {
      progressKey.errorResponse(error: init.exception);
      request.error(Web3RequestExceptionConst.fromException(init.exception!));
      return;
    }
    progressKey.idle();
  }

  void _onChangeForm() {
    notify();
  }

  @override
  void close() {
    super.close();
    liveRequest.removeListener(_onChangeForm);
    form.close();
  }
}
