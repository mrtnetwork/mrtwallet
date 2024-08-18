import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/controller/impl/web3.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/worker.dart';

class Web3EthereumGlobalRequestController<RESPONSE,
        T extends Web3EthereumRequestParam<RESPONSE>>
    extends Web3EthereumImpl<RESPONSE, T> {
  Web3EthereumGlobalRequestController(
      {required super.walletProvider, required super.request});
  void onChangeForm() {
    notify();
  }

  void onCompeleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3EthereumRequestMethods.persoalSign:
        final sign = await walletProvider.wallet
            .walletRequest(WalletRequestEthereumPersonalSign(
          message:
              request.params.cast<Web3EthreumPersonalSign>().chalengBytes(),
          index: address.keyIndex as Bip32AddressIndex,
        ));
        if (sign.hasError) {
          progressKey.error(text: sign.error!.tr);
          return;
        }
        result = sign.result;
        break;
      case Web3EthereumRequestMethods.typedData:
        final sign = await walletProvider.wallet
            .walletRequest(WalletRequestEthereumTypedDataSign(
          message: request.params.cast<Web3EthreumTypdedData>().typedData,
          index: address.keyIndex as Bip32AddressIndex,
        ));
        if (sign.hasError) {
          progressKey.error(text: sign.error!.tr);
          return;
        }
        result = sign.result;
        break;
      default:
    }
    request.completeRequest(result);
    progressKey.response(text: "request_completed_success".tr);
  }

  void _init() {
    MethodUtils.after(() async {
      liveRequest.addListener(onChangeForm);
      form.onCompeleteForm = onCompeleteForm;
      progressKey.idle();
    });
  }

  @override
  Future<void> readyWeb3() async {
    await super.readyWeb3();
    _init();
  }

  @override
  void close() {
    super.close();
    liveRequest.removeListener(onChangeForm);
    form.onCompeleteForm = null;
  }
}
