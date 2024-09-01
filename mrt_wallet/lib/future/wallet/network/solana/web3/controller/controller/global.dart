import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/requets/messages/wallet/requests/personal_sign.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/solana/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3SolanaGlobalRequestController<RESPONSE,
        T extends Web3SolanaRequestParam<RESPONSE>>
    extends Web3SolanaImpl<RESPONSE, T> {
  Web3SolanaGlobalRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);
  void onChangeForm() {
    notify();
  }

  void onCompeleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3SolanaRequestMethods.signMessage:
        final sign = await walletProvider.wallet.walletRequest(
            WalletRequestSignMessage(
                message:
                    request.params.cast<Web3SolanaSignMessage>().chalengBytes(),
                network: NetworkType.solana,
                index: address.keyIndex as Bip32AddressIndex));
        if (sign.hasError) {
          progressKey.error(text: sign.error!.tr);
          return;
        }
        result = sign.result.signature;
        break;
      default:
        break;
    }
    request.completeResponse(result);
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
