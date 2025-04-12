import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/requets/messages/wallet/requests/personal_sign.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/network/tron/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
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
  LiveTransactionForm? _liveRequest;

  TronWeb3Form<T> get form => _liveRequest!.value;

  TronWeb3Form _init() {
    switch (request.params.method) {
      case Web3TronRequestMethods.switchTronChain:
        final switchChainRequest = request.params as Web3TronSwitchChain;
        final tronChains = walletProvider.wallet.getChains<TronChain>();
        final network = tronChains.firstWhereOrNull((e) =>
            e.network.tronNetworkType.genesisBlockNumber ==
            switchChainRequest.chainId.toInt());
        if (network == null) {
          throw Web3RequestExceptionConst.networkDoesNotExists;
        }
        return Web3TronSwitchTronChain(request: request, newChain: network);
      case Web3TronRequestMethods.signMessageV2:
        return Web3TronReadOnlyForm<T>(request: request);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  void onChangeForm() {
    notify();
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3TronRequestMethods.switchTronChain:
        final chain = (form as Web3TronSwitchTronChain).newChain;
        final Web3TronChain? permission = request.currentPermission;
        permission?.setActiveChain(chain.network);
        request.authenticated.updateChainAccount(permission!);
        result = chain.network.tronNetworkType.genesisBlockNumber.toRadix16;
        break;
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
          progressKey.error(error: sign.exception, showBackButton: true);
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
      try {
        final form = _init();
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
