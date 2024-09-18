import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/network/solana/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/page_progress.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/solana/src/rpc/models/models/commitment.dart';
import 'package:on_chain/solana/src/transaction/transaction/transaction.dart';

class Web3SolanaTransactionRequestController extends Web3SolanaImpl<
    List<Map<String, dynamic>>, Web3SolanaSendTransaction> {
  @override
  Web3SolanaSendTransactionForm get form =>
      liveRequest.validator as Web3SolanaSendTransactionForm;
  bool get isMultipleTransaction => request.params.isBatchRequest;
  Web3SolanaSendTransactionOptions? _sendOption;
  bool get isSend => request.params.isSend;
  bool _hasSimulateError = false;
  bool _isReady = false;
  bool get isReady => _isReady;
  bool _canReplaceBlockHash = false;
  bool get canReplaceBlockHash => _canReplaceBlockHash;
  bool _replaceBlockHash = false;
  bool get replaceBlockHash => _replaceBlockHash;
  late final IntegerBalance total = IntegerBalance.zero(network.coinDecimal);
  bool _isMultipleWithSameOwner = false;
  bool get isMultipleWithSameOwner => _isMultipleWithSameOwner;

  Web3SolanaTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  void toggleReplaceBlockHash(bool? _) {
    if (!isSend) return;
    _replaceBlockHash = !_replaceBlockHash;
    notify();
  }

  Future<void> _init() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    try {
      final params = request.params.messages;
      List<SolanaWeb3TransactionInfo> messagess = [];
      for (final i in params) {
        final permission = request.authenticated
            .getChainFromNetworkType<Web3SolanaChain>(NetworkType.solana)
            ?.getAccountPermission(chain: account, address: i.account);

        if (permission == null) {
          throw Web3RequestExceptionConst.missingPermission;
        }
        final message = SolanaTransaction.deserialize(i.messageBytes);
        final simulate = SolanaWeb3TransactionInfo(
            transaction: message, signer: permission, id: i.id);
        messagess.add(simulate);
        apiProvider
            .updateBalance(permission, updateTokens: false)
            .then((e) => _checkTransaction);
      }
      _sendOption = request.params.sendConfig;
      form.init(transactions: messagess, client: apiProvider);
      final hasSameOwner =
          form.transaction.map((e) => e.signer.networkAddress).toSet().length !=
              form.transaction.length;
      _isMultipleWithSameOwner = isMultipleTransaction && hasSameOwner;
      _canReplaceBlockHash =
          isSend && form.transaction.any((e) => e.canUpdateBlockHash);
      progressKey.idle();
    } on Web3RequestException catch (e) {
      progressKey.error(
          text: "web3_permission_error_desc".tr, backToIdle: null);
      request.error(e);
    }
  }

  void _checkTransaction() {
    _hasSimulateError = form.transaction.any((e) => e.status.hasSimulateError);
    _isReady = !form.transaction.any((e) => !e.status.isSuccess);
    final totalAccountsBalances = form.transaction
        .fold(BigInt.zero, (p, c) => p + c.signer.address.currencyBalance);
    final totalSol = form.transaction
        .fold(BigInt.zero, (p, c) => p + c.accountChange.balance);
    total.updateBalance(totalAccountsBalances - totalSol);
    notify();
  }

  Future<void> confirm(
      Future<bool?> Function(String error) onFailedInstruction) async {
    if (!_isReady) {
      final accept = await onFailedInstruction(_hasSimulateError
          ? "simulation_failed_continue_desc".tr
          : "simulation_process_continue_desc".tr);
      if (accept != true) return;
    }
    progressKey.process(text: "signing_transaction_please_wait".tr);
    if (_canReplaceBlockHash) {
      await form.replateBlockHash();
    }
    final signerAccounts = form.transaction.map((e) => e.signer).toList();

    final signedTr = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: signerAccounts,
      sign: (generateSignature) async {
        final List<SolanaWeb3SignedTransactionInfo> signatures = [];
        for (final i in form.transaction) {
          final digest =
              List<int>.unmodifiable(i.transaction.serializeMessage());
          final signer = i.signer.keyIndex as Bip32AddressIndex;
          final signRequest =
              GlobalSignRequest.solana(digest: digest, index: signer);
          final signingResponse = await generateSignature(signRequest);
          i.transaction
              .addSignature(i.signer.networkAddress, signingResponse.signature);
          final signignInfo = SolanaWeb3SignedTransactionInfo(
              info: i, signature: signingResponse.signature);
          signatures.add(signignInfo);
        }
        return signatures;
      },
    ));
    if (signedTr.hasError) {
      progressKey.error(text: signedTr.error!.tr);
      return;
    }
    final List<SolanaWeb3SignedTransactionInfo> result = signedTr.result;
    final List<SolanaWeb3TransactionResponse> response = [];

    if (isSend) {
      progressKey.process(
          text: "create_send_transaction".tr.replaceOne(network.token.name));
      for (final i in result) {
        final signer = i.info.signer.networkAddress;
        final result = await MethodUtils.call(
            () async => await apiProvider.sendTransaction(
                  i.info.transaction,
                  skipPreflight: _sendOption?.skipPreflight ?? false,
                  maxRetries: _sendOption?.maxRetries ?? 5,
                  minContextSlot: _sendOption?.minContextSlot,
                  commitment: Commitment.fromName(_sendOption?.commitment ?? "",
                      defaultValue: Commitment.processed),
                ));
        if (result.hasResult) {
          response.add(SolanaWeb3TransactionSendResponse(
              id: i.info.id,
              txHash: result.result,
              signer: signer.address,
              signerAddressBytes: signer.toBytes()));
        } else {
          if (!isMultipleTransaction) {
            request.error(
                Web3RequestExceptionConst.fromException(result.exception!));
            progressKey.error(text: result.error!.tr, backToIdle: null);
            return;
          }
          response.add(SolanaWeb3TransactionErrorResponse(
              id: i.info.id,
              message: result.error!.tr,
              signer: signer.address,
              signerAddressBytes: signer.toBytes()));
        }
      }
    } else {
      response.addAll(result.map((e) {
        final signer = e.info.signer.networkAddress;
        return SolanaWeb3TransactionSignResponse(
            id: e.info.id,
            signature: e.signature,
            signer: signer.address,
            signerAddressBytes: signer.toBytes());
      }));
    }

    request.completeResponse(response.map((e) => e.toJson()).toList());
    if (isSend) {
      progressKey.response(
          widget: ProgressMultipleTextView(
              texts: response.map((e) {
                if (e.type == SolanaWeb3TransactionResponseType.error) {
                  final SolanaWeb3TransactionErrorResponse err = e.cast();
                  return ProgressMultipleTextViewObject.error(
                      message: err.message);
                }
                final SolanaWeb3TransactionSendResponse txResult = e.cast();
                return ProgressMultipleTextViewObject.success(
                    message: txResult.txHash,
                    openUrl: network.coinParam
                        .getTransactionExplorer(txResult.txHash));
              }).toList(),
              logo: network.token.assetLogo,
              title: network.networkName));
    } else {
      progressKey.response(text: "transaction_signed".tr);
    }
  }

  void onChange([bool? changed]) {
    _checkTransaction();
  }

  @override
  Future<void> readyWeb3() async {
    await super.readyWeb3();
    form.onChanged = onChange;
    _init();
  }
}
