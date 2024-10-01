import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/future/state_managment/extension/app_extensions/string.dart';
import 'package:mrt_wallet/future/wallet/network/forms/stellar/stellar.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/constant/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarTransactionRequestController
    extends Web3StellarImpl<String, Web3StellarSendTransaction> {
  Web3StellarTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  late final StellarWeb3TransactionDetails transactionInfo;
  late final StellarAccountResponse accountInfo;
  bool get isSendTransaction =>
      request.params.method == Web3StellarRequestMethods.sendTransaction;

  @override
  Web3StellarSendTransactionForm get form =>
      liveRequest.validator as Web3StellarSendTransactionForm;

  Future<Envelope> _signTransaction() async {
    final transaction = request.params.transaction.tx;
    final payload = TransactionSignaturePayload(
        taggedTransaction: transaction,
        networkId: network.coinParam.passphraseHash());

    final List<int> digest = payload.txHash().asImmutableBytes;
    final signingRequest = WalletSigningRequest(
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
        await walletProvider.wallet.signTransaction(request: signingRequest);
    return request.params.transaction.copyWith(signatures: [
      ...request.params.transaction.signatures,
      ...result.result
    ]);
  }

  Future<void> sendTransaction() async {
    progressKey.process(
        text: "create_send_transaction"
            .tr
            .replaceOne(network.coinParam.token.name));

    final signedEnvlope = await MethodUtils.call(() async {
      return await _signTransaction();
    });

    if (signedEnvlope.hasError) {
      progressKey.error(text: signedEnvlope.error!.tr);
      return;
    }
    final envlopeXdr = signedEnvlope.result.toVariantXDRBase64();
    if (isSendTransaction) {
      final result = await MethodUtils.call(
          () async => await apiProvider.submitTx(envlopeXdr));
      if (result.hasError) {
        progressKey.error(text: result.error!.tr, backToIdle: null);
        request
            .error(Web3RequestExceptionConst.fromException(result.exception!));
        return;
      }
      request.completeResponse(result.result.hash);
      progressKey.responseTx(hash: result.result.hash, network: network);
      return;
    }
    request.completeResponse(envlopeXdr);
    progressKey.response(text: "transaction_signed".tr);
  }

  Future<void> _init() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final result = await MethodUtils.call(() async {
      final envlope = request.params.transaction;
      final accountResponse =
          await apiProvider.getAccountFromIStellarAddress(address);
      if (accountResponse == null) return null;
      final transactionInfo = await apiProvider.getWeb3TransactionInfo(
          envlope: envlope,
          chain: account,
          signer: address,
          signerAccountInfo: accountResponse);
      return (accountResponse, transactionInfo);
    });
    if (result.hasError) {
      progressKey.error(text: result.error!.tr, backToIdle: null);
      return;
    }
    if (result.result == null) {
      progressKey.error(text: "account_not_found".tr, backToIdle: null);
      return;
    }
    accountInfo = result.result!.$1;
    transactionInfo = result.result!.$2;
    progressKey.idle();
  }

  @override
  Future<void> readyWeb3() async {
    await super.readyWeb3();
    _init();
  }
}
