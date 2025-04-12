import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/messages/wallet/requests/bitcoin_personal_sign.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3BitcoinGlobalRequestController<RESPONSE,
        T extends Web3BitcoinRequestParam<RESPONSE>>
    extends Web3BitcoinImpl<RESPONSE, T> {
  @override
  bool get clientRequired => false;
  Web3BitcoinGlobalRequestController(
      {required super.walletProvider, required super.request})
      : super(account: request.chain);
  void onChangeForm() {
    notify();
  }

  BitcoinWeb3Form<T> _init() {
    switch (request.params.method) {
      case Web3BitcoinRequestMethods.signPersonalMessage:
        return Web3BitcoinSignMessageForm(
            request: request as Web3BitcoinRequest<
                Web3BitcoinSignMessageResponse,
                Web3BitcoinSignMessage>) as BitcoinWeb3Form<T>;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  LiveTransactionForm? _liveRequest;
  BitcoinWeb3Form<T> get form => _liveRequest!.value;

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3BitcoinRequestMethods.requestAccounts:
        final web3Chain = result as Web3BitcoinChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3BitcoinRequestMethods.signPersonalMessage:
        final param = form as Web3BitcoinSignMessageForm;
        final sign = await walletProvider.wallet.walletRequest(
            WalletRequestBitcoinSignMessage(
                message: param.challengeBytes(),
                index: address.keyIndex.cast(),
                messagePrefix: param.messagePrefix,
                mode: param.mode));
        if (sign.hasError) {
          progressKey.error(error: sign.exception, showBackButton: true);
          return;
        }
        result = Web3BitcoinSignMessageResponse(
            signature: sign.result.signatureBase64, digest: sign.result.digest);
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
      try {
        final form = _init();
        _liveRequest = LiveTransactionForm(validator: form);
        _liveRequest?.addListener(onChangeForm);
        form.onCompleteForm = onCompleteForm;
        await form.initForm(
            account: account, address: request.accountPermission());
        progressKey.idle();
      } catch (e) {
        progressKey.errorResponse(error: e);
        final error = Web3RequestExceptionConst.fromException(e);
        request.error(error);
      }
    });
  }

  @override
  void close() {
    super.close();
    _liveRequest?.removeListener(onChangeForm);
    form.onCompleteForm = null;
  }
}
