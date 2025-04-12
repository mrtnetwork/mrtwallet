import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3CosmosGlobalRequestController<RESPONSE,
        T extends Web3CosmosRequestParam<RESPONSE>>
    extends Web3CosmosImpl<RESPONSE, T> {
  @override
  bool get clientRequired => false;
  Web3CosmosGlobalRequestController(
      {required super.walletProvider, required super.request})
      : super(account: request.chain);
  void onChangeForm() {
    notify();
  }

  CosmosWeb3Form<T> _init() {
    switch (request.params.method) {
      case Web3CosmosRequestMethods.signMessage:
        return Web3CosmosSignMessageForm(request: request.cast())
            as CosmosWeb3Form<T>;
      case Web3CosmosRequestMethods.addNewChain:
        return Web3CosmosAddNewChainForm(request: request.cast())
            as CosmosWeb3Form<T>;
      case Web3CosmosRequestMethods.switchNetwork:
        final switchChainRequest = request.params as Web3CosmosSwitchChain;
        final cosmosChains = walletProvider.wallet.getChains<CosmosChain>();
        final chain = cosmosChains.firstWhereOrNull(
            (e) => e.network.coinParam.chainId == switchChainRequest.chainId);
        if (chain == null) {
          throw Web3RequestExceptionConst.invalidRequest;
        }
        return Web3CosmosSwitchCosmosChain(request: request, newChain: chain)
            as CosmosWeb3Form<T>;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  LiveTransactionForm? _liveRequest;
  CosmosWeb3Form<T> get form => _liveRequest!.value;

  Future<Web3CosmosSignMessageResponse> _signMessage() async {
    final form = this.form as Web3CosmosSignMessageForm;
    final message = form.challengeBytes();
    final signRequest = WalletSigningRequest(
      addresses: [address],
      network: network,
      sign: (generateSignature) async {
        final signRequest = CosmosSigningRequest(
            digest: form.challengeBytes(),
            index: address.keyIndex,
            alg: address.algorithm);
        final response = await generateSignature(signRequest);
        return response.signature;
      },
    );
    final signatures =
        await walletProvider.wallet.signTransaction(request: signRequest);
    return Web3CosmosSignMessageResponse(
        messageBytes: message, signature: signatures.result);
  }

  Future<void> _importNewChain() async {
    final form = (this.form as Web3CosmosAddNewChainForm).form;
    if (!(form.formKey.currentState?.validate() ?? false)) return;
    final rpcUrl = form.getRpcUrl();
    if (rpcUrl == null) return;
    progressKey.process(text: "processing_request".tr);
    final r = await MethodUtils.call(() async {
      final networkParams = await form.createNetwork();
      if (networkParams == null) {
        throw WalletException("some_required_field_not_filled");
      }
      await walletProvider.wallet
          .updateImportNetwork(WalletCosmosNetwork(-1, networkParams));
    });
    if (r.hasError) {
      progressKey.error(error: r.exception, showBackButton: true);
      return;
    }
    request.completeResponse(true);
    progressKey.response(text: "request_completed_success".tr);
  }

  void onCompleteForm(Object? obj) async {
    if (request.params.method == Web3CosmosRequestMethods.addNewChain) {
      return _importNewChain();
    }
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3CosmosRequestMethods.requestAccounts:
        final web3Chain = result as Web3CosmosChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3CosmosRequestMethods.switchNetwork:
        final network = (form as Web3CosmosSwitchCosmosChain).newChain;
        final Web3CosmosChain? permission = request.currentPermission;
        permission?.setActiveChain(network.network);
        request.authenticated.updateChainAccount(permission!);
        result = true;
        break;
      case Web3CosmosRequestMethods.signMessage:
        if (obj != true) {
          progressKey.idle();
          return;
        }
        final signMessage = await MethodUtils.call(() => _signMessage());
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
