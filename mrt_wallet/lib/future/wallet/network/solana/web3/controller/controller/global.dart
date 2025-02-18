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
        if (obj != true) {
          progressKey.idle();
          return;
        }
        final signingParams = request.params as Web3SolanaSignMessage;
        final messageBytes = signingParams.chalengBytes();
        final signMessage = await MethodUtils.call(() async {
          final signature = await walletProvider.wallet.signTransaction(
              request: WalletSigningRequest(
            addresses: [address],
            network: network,
            sign: (generateSignature) async {
              final signRequest = GlobalSignRequest.solana(
                  digest: messageBytes, index: address.keyIndex.cast());
              final response = await generateSignature(signRequest);
              return response.signature;
            },
          ));
          return signature.result;
        });
        if (signMessage.hasError) {
          progressKey.error(error: signMessage.exception, showBackButton: true);
          return;
        }
        result = Web3SolanaSignMessageResponse(
            address: address.networkAddress,
            signature: signMessage.result,
            signedMessage: messageBytes);
        break;
      default:
        break;
    }
    request.completeResponse(result);
    progressKey.response(text: "request_completed_success".tr);
  }

  @override
  Future<void> initWeb3() async {
    await MethodUtils.after(() async {
      liveRequest.addListener(onChangeForm);
      form.onCompleteForm = onCompleteForm;
      progressKey.idle();
    });
  }

  @override
  void close() {
    super.close();
    liveRequest.removeListener(onChangeForm);
    form.onCompleteForm = null;
  }
}
