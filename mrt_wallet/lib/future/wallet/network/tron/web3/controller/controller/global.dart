import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/requets/messages/wallet/requests/personal_sign.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/tron/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3TronGlobalRequestController<RESPONSE,
        T extends Web3TronRequestParam<RESPONSE>>
    extends Web3TronImpl<RESPONSE, T> {
  Web3TronGlobalRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  @override
  bool get clientRequired => false;
  void onChangeForm() {
    notify();
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3TronRequestMethods.requestAccounts:
        final web3Chain = result as Web3TronChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3TronRequestMethods.signMessageV2:
        final sign = await walletProvider.wallet.walletRequest(
            WalletRequestSignMessage(
                message:
                    request.params.cast<Web3TronSignMessageV2>().chalengBytes(),
                index: address.keyIndex.cast(),
                network: NetworkType.tron));
        if (sign.hasError) {
          progressKey.error(text: sign.error!.tr);
          return;
        }
        result = sign.result.signatureHex;
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
