import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/solana/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3SolanaGlobalRequestController<RESPONSE,
        T extends Web3SolanaRequestParam<RESPONSE>>
    extends Web3SolanaImpl<RESPONSE, T> {
  @override
  bool get clientRequired => false;
  Web3SolanaGlobalRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);
  void onChangeForm() {
    notify();
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3SolanaRequestMethods.requestAccounts:
        final web3Chain = result as Web3SolanaChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3SolanaRequestMethods.signMessage:
      case Web3SolanaRequestMethods.signIn:
        final messages = obj;
        if (messages is! List<Web3SolanaSignParams>) {
          progressKey.idle();
          return;
        }
        final signers = messages
            .map((e) => request.currentPermission!
                .getAccountPermission(account: e.account, chain: account))
            .toList();
        final signMessage = await MethodUtils.call(() async {
          final signature = await walletProvider.wallet.signTransaction(
              request: WalletSigningRequest(
            addresses: signers,
            network: network,
            sign: (generateSignature) async {
              final List<Web3SolanaSignMessageResponse> signedMessages = [];
              for (int i = 0; i < signers.length; i++) {
                final msg = messages[i];
                final signer = signers[i];
                final signMessage = msg.dataBytes();
                final signRequest = GlobalSignRequest.solana(
                    digest: signMessage, index: signer.keyIndex.cast());
                final response = await generateSignature(signRequest);
                signedMessages.add(Web3SolanaSignMessageResponse(
                    address: signer.networkAddress,
                    signature: response.signature,
                    signedMessage: signMessage));
              }

              return signedMessages;
            },
          ));
          return signature.result;
        });
        if (signMessage.hasError) {
          progressKey.error(error: signMessage.exception, showBackButton: true);
          return;
        }
        result = signMessage.result;
        break;
      default:
        break;
    }
    request.completeResponse(result);
    progressKey.response(text: "request_completed_success".tr);
  }

  @override
  Future<void> initWeb3() async {
    liveRequest.addListener(onChangeForm);
    form.onCompleteForm = onCompleteForm;
    final init = await MethodUtils.call(
        () => form.initForm(account: account, address: null));
    if (init.hasError) {
      progressKey.errorResponse(error: init.exception);
      request.error(Web3RequestExceptionConst.fromException(init.exception!));
      return;
    }
    progressKey.idle();
  }

  @override
  void close() {
    super.close();
    liveRequest.removeListener(onChangeForm);
    form.onCompleteForm = null;
  }
}
