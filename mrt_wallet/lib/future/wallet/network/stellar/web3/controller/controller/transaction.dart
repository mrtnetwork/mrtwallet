import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/future/state_managment/extension/app_extensions/string.dart';
import 'package:mrt_wallet/future/wallet/network/forms/stellar/stellar.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/constant/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/stellar/addresses/stellar.dart';
import 'package:mrt_wallet/wallet/models/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarTransactionRequestController extends Web3StellarImpl<
    Web3StellarSendTransactionResponse, Web3StellarSendTransaction> {
  Web3StellarTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  late final StellarWeb3TransactionDetails transactionInfo;
  late final StellarAccountResponse accountInfo;
  bool get isSendTransaction =>
      request.params.method == Web3StellarRequestMethods.sendTransaction;

  Envelope get _transaction => transactionInfo.envelope;
  late IStellarAddress _address;

  @override
  Web3StellarSendTransactionForm get form =>
      liveRequest.validator as Web3StellarSendTransactionForm;

  Future<Envelope> _signTransaction() async {
    final transaction = _transaction.tx;
    final payload = TransactionSignaturePayload(
        taggedTransaction: transaction,
        networkId: network.coinParam.stellarChainType.passphraseHash);

    final List<int> digest = payload.txHash().asImmutableBytes;
    final signingRequest = WalletSigningRequest(
        addresses: [_address],
        network: network,
        sign: (sign) async {
          final request = GlobalSignRequest.stellar(
              digest: digest, index: _address.keyIndex.cast());
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
    return _transaction
        .copyWith(signatures: [..._transaction.signatures, ...result.result]);
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
      progressKey.error(error: signedEnvlope.exception, showBackButton: true);
      return;
    }
    final envlopeXdr = signedEnvlope.result.toVariantXDRBase64();
    if (isSendTransaction) {
      final result = await MethodUtils.call(
          () async => await apiProvider.submitTx(envlopeXdr));
      if (result.hasError) {
        progressKey.errorResponse(error: result.exception);
        request
            .error(Web3RequestExceptionConst.fromException(result.exception!));
        return;
      }
      final txId = result.result?.hash ??
          signedEnvlope.result
              .txId(network.coinParam.stellarChainType.passphraseHash);
      final response =
          Web3StellarSendTransactionResponse(envlope: envlopeXdr, txHash: txId);
      request.completeResponse(response);
      progressKey.responseTx(hash: txId, network: network);
      return;
    }
    final response = Web3StellarSendTransactionResponse(envlope: envlopeXdr);
    request.completeResponse(response);
    progressKey.response(text: "transaction_signed".tr);
  }

  @override
  Future<void> initWeb3() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final result = await MethodUtils.call(() async {
      final web3Account = request.currentPermission!;
      final tx = MethodUtils.nullOnException(
          () => Envelope.fromXdr(request.params.transaction));
      if (tx == null) {
        throw Web3StellarExceptionConstant.invalidAccountOrTransaction;
      }
      StellarAddress sourceAddress;
      if (tx.tx.type == EnvelopeType.txFeeBump) {
        final feeBumpTx = tx.tx.cast<StellarFeeBumpTransaction>();
        sourceAddress = feeBumpTx.feeSource.address;
      } else {
        final txV1 = tx.tx.cast<StellarTransactionV1>();
        sourceAddress = txV1.sourceAccount.address;
      }
      final sourceAccount = web3Account.getAddressPermission(sourceAddress);
      IStellarAddress address;
      if (sourceAccount != null) {
        address = web3Account.getAccountPermission(
            account: sourceAccount, chain: account);
      } else {
        address = request.accountPermission()!;
      }
      final accountResponse =
          await apiProvider.getAccountFromIStellarAddress(address, account);
      if (accountResponse == null) return null;
      final transactionInfo = await apiProvider.getWeb3TransactionInfo(
          envlope: tx,
          chain: account,
          signer: address,
          signerAccountInfo: accountResponse);
      return (accountResponse, transactionInfo, address);
    });
    if (result.hasError) {
      progressKey.errorResponse(error: result.exception);
      return;
    }
    if (result.result == null) {
      progressKey.errorResponse(message: "account_not_found".tr);
      return;
    }
    accountInfo = result.result!.$1;
    transactionInfo = result.result!.$2;
    _address = result.result!.$3;
    progressKey.idle();
  }
}
