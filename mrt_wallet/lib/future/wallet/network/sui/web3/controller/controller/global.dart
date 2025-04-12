import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/requets/messages/messages.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/network/sui/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/sui/sui.dart';

class Web3SuiGlobalRequestController<RESPONSE,
    T extends Web3SuiRequestParam<RESPONSE>> extends Web3SuiImpl<RESPONSE, T> {
  @override
  bool get clientRequired => false;
  Web3SuiGlobalRequestController(
      {required super.walletProvider, required super.request})
      : super(account: request.chain);
  void onChangeForm() {
    notify();
  }

  SuiWeb3Form<T> _init() {
    switch (request.params.method) {
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
        return Web3SuiSignMessageForm(
                request: request
                    as Web3SuiRequest<Map<String, dynamic>, Web3SuiSignMessage>)
            as SuiWeb3Form<T>;

      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  LiveTransactionForm? _liveRequest;
  SuiWeb3Form<T> get form => _liveRequest!.value;

  Future<Map<String, dynamic>> _signMessage() async {
    final Web3SuiSignMessageForm form = this.form as Web3SuiSignMessageForm;
    final signingMessage = form.challengeBytes().asImmutableBytes;
    final digest = SuiCryptoUtils.generatePersonalMessageDigest(signingMessage);
    final signatures = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: [address],
      sign: (generateSignature) async {
        if (address.multiSigAccount) {
          final multisigAccount = address as ISuiMultiSigAddress;
          List<SuiGenericSignature> signatures = [];
          int weight = 0;
          for (final i in multisigAccount.multiSignatureAddress.publicKeys) {
            final Bip32AddressIndex signer = i.keyIndex;
            final signRequest =
                GlobalSignRequest.sui(digest: digest, index: signer);
            final signature = await generateSignature(signRequest);
            signatures.add(SuiGenericSignature(
                signature: signature.signature,
                algorithm: i.keyScheme.suiKeyAlgorithm));
            weight += i.weight;
            if (weight >= multisigAccount.multiSignatureAddress.threshold) {
              break;
            }
          }
          if (weight < multisigAccount.multiSignatureAddress.threshold) {
            throw WalletException("insufficient_signatures");
          }
          return signatures;
        } else {
          final Bip32AddressIndex signer = address.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.sui(digest: digest, index: signer);
          final signature = await generateSignature(signRequest);
          final suiSignature = SuiGenericSignature(
              signature: signature.signature,
              algorithm: address.keyScheme.suiKeyAlgorithm);
          return [suiSignature];
        }
      },
    ));
    final signature = address.createTransactionAuthenticated(signatures.result);
    final signedMessage = Web3SuiSignMessageResponse(
        messageBytes:
            StringUtils.decode(signingMessage, type: StringEncoding.base64),
        signature: signature.toVariantBcsBase64());
    return signedMessage.toJson();
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3SuiRequestMethods.requestAccounts:
        final web3Chain = result as Web3SuiChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
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
