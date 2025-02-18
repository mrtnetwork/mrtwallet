import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/requets/messages.dart';
import 'package:mrt_wallet/crypto/utils/aptos/aptos.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/aptos/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/aptos/src/account/authenticator/authenticator.dart';

class Web3AptosTransactionRequestController
    extends Web3AptosImpl<List<int>, Web3AptosSendTransaction> {
  late final LiveTransactionForm<Web3AptosSendTransactionForm> _liveRequest =
      LiveTransactionForm(
          validator: Web3AptosSendTransactionForm(request: request));
  Web3AptosSendTransactionForm get form => _liveRequest.validator;

  Web3AptosTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  Future<AptosAccountAuthenticator> _signTransaction() async {
    final rawTransaction = request.params.transaction;
    final signingDigest = rawTransaction.signingSerialize(
        feePayerAddress: request.params.feePayer,
        secondarySignerAddresses: request.params.secondarySignerAddresses);
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
            final signRequest =
                GlobalSignRequest.aptos(digest: signingDigest, index: signer);
            final signature = await generateSignature(signRequest);
            signatures.add(AptosUtils.generateSignature(
                signature.signature, publicKey.keyScheme.curve));
          }
          return signatures;
        }
        final Bip32AddressIndex signer = address.keyIndex.cast();
        final signRequest =
            GlobalSignRequest.aptos(digest: signingDigest, index: signer);
        final signature = await generateSignature(signRequest);
        return [
          AptosUtils.generateSignature(
              signature.signature, address.keyScheme.curve)
        ];
      },
    ));
    final accountAuthenticators =
        address.createAccountAuthenticated(signedTr.result);
    return accountAuthenticators;
  }

  Future<void> _onCompleteForm(Object? _) async {
    progressKey.process(text: "signing_transaction_please_wait".tr);
    final transaction = await MethodUtils.call(() => _signTransaction());
    if (transaction.hasError) {
      progressKey.error(error: transaction.exception, showBackButton: true);
      return;
    }

    request.completeResponse(transaction.result.toVariantBcs());
    progressKey.response(text: "transaction_signed".tr);
  }

  @override
  Future<void> initWeb3() async {
    _liveRequest.addListener(_onChangeForm);
    form.onCompleteForm = _onCompleteForm;
    form.initForm(account: account, address: address);
    progressKey.idle();
  }

  void _onChangeForm() {
    notify();
  }

  @override
  void close() {
    super.close();
    _liveRequest.removeListener(_onChangeForm);
    form.close();
  }
}
