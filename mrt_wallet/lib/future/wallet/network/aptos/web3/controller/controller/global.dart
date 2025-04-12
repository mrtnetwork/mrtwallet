import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/crypto/utils/aptos/aptos.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/aptos/src/account/authenticator/authenticator.dart';

class Web3AptosGlobalRequestController<RESPONSE,
        T extends Web3AptosRequestParam<RESPONSE>>
    extends Web3AptosImpl<RESPONSE, T> {
  @override
  bool get clientRequired => false;
  Web3AptosGlobalRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);
  void onChangeForm() {
    notify();
  }

  AptosWeb3Form<T> _init() {
    switch (request.params.method) {
      case Web3AptosRequestMethods.signMessage:
        return Web3AptosSignMessageForm(
            request: request as Web3AptosRequest<Web3AptosSignMessageResponse,
                Web3AptosSignMessage>) as AptosWeb3Form<T>;

      case Web3AptosRequestMethods.switchNetwork:
        final switchChainRequest = request.params as Web3AptosSwitchChain;
        final aptosChains = walletProvider.wallet.getChains<AptosChain>();
        final chain = aptosChains.firstWhereOrNull((e) =>
            e.network.coinParam.aptosChainType == switchChainRequest.chainType);
        if (chain == null) {
          throw Web3RequestExceptionConst.networkDoesNotExists;
        }
        return Web3AptosSwitchAptosChain(request: request, newChain: chain)
            as AptosWeb3Form<T>;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  LiveTransactionForm? _liveRequest;
  AptosWeb3Form<T> get form => _liveRequest!.value;

  Future<Web3AptosSignMessageResponse> _signMessage() async {
    final messageForm = form as Web3AptosSignMessageForm;
    final signedTr = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: [address],
      sign: (generateSignature) async {
        if (address.multiSigAccount) {
          List<AptosAnySignature> signatures = [];
          final multisigAddress =
              address.cast<IAptosMultiSigAddress>().multiSignatureAddress;
          for (int i = 0; i < multisigAddress.requiredSignature; i++) {
            final publicKey = multisigAddress.publicKeys[i];
            final Bip32AddressIndex signer = publicKey.keyIndex;
            final signRequest = GlobalSignRequest.aptos(
                digest: messageForm.payloadMessage, index: signer);
            final signature = await generateSignature(signRequest);
            signatures.add(AptosUtils.generateSignature(
                signature.signature, publicKey.keyScheme.curve));
          }
          return signatures;
        }
        final Bip32AddressIndex signer = address.keyIndex.cast();
        final signRequest = GlobalSignRequest.aptos(
            digest: messageForm.payloadMessage, index: signer);
        final signature = await generateSignature(signRequest);
        return [
          AptosUtils.generateSignature(
              signature.signature, address.keyScheme.curve)
        ];
      },
    ));
    final auth = address.createAccountAuthenticated(signedTr.result);
    final signature = auth.signature.toBytes();
    return messageForm.buildResponse(signature);
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3AptosRequestMethods.switchNetwork:
        final network = (form as Web3AptosSwitchAptosChain).newChain;
        final Web3AptosChain? permission = request.currentPermission;
        permission?.setActiveChain(network.network);
        request.authenticated.updateChainAccount(permission!);
        result = true;
        break;
      case Web3AptosRequestMethods.requestAccounts:
        final web3Chain = result as Web3AptosChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3AptosRequestMethods.signMessage:
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
