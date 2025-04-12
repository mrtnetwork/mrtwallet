import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/controller/impl/web3.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ethereum/ethereum.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/worker.dart';

class Web3EthereumGlobalRequestController<RESPONSE,
        T extends Web3EthereumRequestParam<RESPONSE>>
    extends Web3EthereumImpl<RESPONSE, T> {
  Web3EthereumGlobalRequestController(
      {required super.walletProvider, required super.request});

  @override
  bool get clientRequired => false;
  void onChangeForm() {
    notify();
  }

  LiveTransactionForm? _liveRequest;

  EthereumWeb3Form<T> get form => _liveRequest!.value;

  Future<EthereumWeb3Form> _init() async {
    switch (request.params.method) {
      case Web3EthereumRequestMethods.switchEthereumChain:
        final switchChainRequest = request.params as Web3EthreumSwitchChain;
        final ethChains = walletProvider.wallet.getChains<EthereumChain>();
        final network = ethChains
            .firstWhereOrNull((e) => e.chainId == switchChainRequest.chainId);
        if (network == null) {
          throw Web3RequestExceptionConst.networkDoesNotExists;
        }
        return Web3EthereumSwitchEthereumChain(
            request: request, newChain: network);
      default:
        return Web3EthereumReadOnlyForm<T>(request: request);
    }
  }

  void onCompleteForm(Object? response) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = response;
    switch (request.params.method) {
      case Web3EthereumRequestMethods.switchEthereumChain:
        final chain = form.cast<Web3EthereumSwitchEthereumChain>().newChain;
        final Web3EthereumChain? permission = request.currentPermission;
        permission?.setActiveChain(chain.network);
        request.authenticated.updateChainAccount(permission!);
        result = chain.chainId.toRadix16;
        break;
      case Web3EthereumRequestMethods.requestAccounts:
        final web3Chain = result as Web3EthereumChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3EthereumRequestMethods.persoalSign:
        final sign = await walletProvider.wallet.walletRequest(
            WalletRequestSignMessage(
                message: request.params
                    .cast<Web3EthreumPersonalSign>()
                    .chalengBytes(),
                index: address.keyIndex.cast()));
        if (sign.hasError) {
          progressKey.error(error: sign.exception, showBackButton: true);
          return;
        }
        result = sign.result.signatureHex;
        break;
      case Web3EthereumRequestMethods.typedData:
        final sign = await walletProvider.wallet
            .walletRequest(WalletRequestEthereumTypedDataSign(
          message: request.params.cast<Web3EthreumTypdedData>().typedData,
          index: address.keyIndex.cast(),
        ));
        if (sign.hasError) {
          progressKey.error(error: sign.exception, showBackButton: true);
          return;
        }
        result = sign.result;
        break;
      default:
    }
    request.completeResponse(result);
    progressKey.response(text: "request_completed_success".tr);
  }

  @override
  Future<void> initWeb3() async {
    await MethodUtils.after(() async {
      try {
        final form = await _init();
        _liveRequest = LiveTransactionForm(validator: form);
        _liveRequest?.addListener(onChangeForm);
        form.onCompleteForm = onCompleteForm;
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
