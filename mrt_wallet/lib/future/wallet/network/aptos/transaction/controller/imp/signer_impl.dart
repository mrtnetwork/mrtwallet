import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/crypto/utils/aptos/aptos.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/transaction/controller/imp/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain/aptos/src/aptos.dart';

mixin AptosSignerImpl on AptosTransactionImpl {
  BigInt? _accountSequenceNumber;
  AptosTransactionPayload createTransactionPayload();
  final Cancelable _cancelable = Cancelable();
  int? _chainId;
  @override
  Future<AptosSignedTransaction> createTransaction(
      {BigInt? maxGasAmount,
      BigInt? gasUnitPrice,
      bool simulateTx = false}) async {
    final transactionPayload = createTransactionPayload();
    final expire = BigInt.from(
        DateTime.now().add(const Duration(minutes: 2)).millisecondsSinceEpoch ~/
            1000);
    _accountSequenceNumber ??=
        await apiProvider.getAccountSequence(address.networkAddress);
    maxGasAmount ??= AptosConstants.defaultMinGasAmount;
    gasUnitPrice ??= await apiProvider.getGasUnitPrice();
    _chainId ??= await apiProvider.getCurrenctChainId();
    final rawTransaction = AptosRawTransaction(
        sender: address.networkAddress,
        sequenceNumber: _accountSequenceNumber!,
        transactionPayload: transactionPayload,
        maxGasAmount: maxGasAmount,
        gasUnitPrice: gasUnitPrice,
        expirationTimestampSecs: expire,
        chainId: _chainId!);
    final signingDigest = rawTransaction.signingSerialize();
    if (simulateTx) {
      return AptosSignedTransaction(
          rawTransaction: rawTransaction,
          authenticator: AptosTransactionAuthenticatorSignleSender(
              AptosAccountAuthenticatorNoAccountAuthenticator()));
    } else {
      final signedTr = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest(
        network: network,
        addresses: [address],
        sign: (generateSignature) async {
          if (address.multiSigAccount) {
            List<AptosAnySignature> signatures = [];
            final multisigAddress =
                address.cast<IAptosMultiSigAddress>().multiSignatureAddress;
            for (int i = 0; i < multisigAddress.requiredSignature; i++) {
              final publicKey = multisigAddress.publicKeys[i];
              final Bip32AddressIndex signer = publicKey.keyIndex;
              final signRequest =
                  GlobalSignRequest.aptos(digest: signingDigest, index: signer);
              final signature = await generateSignature(signRequest);
              signatures.add(AptosUtils.generateSignature(
                  signature.signature, publicKey.keyScheme.curve));
            }
            return signatures;
          }
          final Bip32AddressIndex signer = address.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.aptos(digest: signingDigest, index: signer);
          final signature = await generateSignature(signRequest);
          return [
            AptosUtils.generateSignature(
                signature.signature, address.keyScheme.curve)
          ];
        },
      ));
      final accountAuthenticators =
          address.createAccountAuthenticated(signedTr.result);
      return AptosSignedTransaction(
          rawTransaction: rawTransaction,
          authenticator:
              AptosTransactionAuthenticatorSignleSender(accountAuthenticators));
    }
  }

  Future<void> buildAndSignTransaction(
      {BigInt? maxGasAmount, BigInt? gasUnitPrice}) async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final transaction = await MethodUtils.call(
        () => createTransaction(
              maxGasAmount: maxGasAmount,
              gasUnitPrice: gasUnitPrice,
            ),
        cancelable: _cancelable);
    if (transaction.hasError) {
      progressKey.errorText(transaction.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    _cancelable.dispose();
    final result = await MethodUtils.call(() async {
      return await apiProvider.submitTransaction(transaction.result);
    }, cancelable: _cancelable);

    if (result.hasError) {
      _accountSequenceNumber = null;
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
              network: network,
              txIds: [result.result.$1],
              error: result.result.$2
                  ? null
                  : "tx_submit_response_failed_desc".tr),
          backToIdle: false);
    }
  }

  @override
  void close() {
    super.close();
    _cancelable.cancel();
  }
}
