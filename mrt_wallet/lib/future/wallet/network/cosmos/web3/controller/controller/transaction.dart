import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3CosmosTransactionRequestController extends Web3CosmosImpl<
    Web3CosmosSignTransactionResponse, Web3CosmosSignTransaction> {
  late final LiveTransactionForm<Web3CosmosSendTransactionForm> liveRequest =
      LiveTransactionForm(
          validator: Web3CosmosSendTransactionForm(request: request));
  Web3CosmosSendTransactionForm get form => liveRequest.validator;
  final Cancelable _cancelable = Cancelable();

  Web3CosmosTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  Future<void> _onCompleteForm(Object? digest) async {
    if (digest is! List<int>) return;
    progressKey.process(text: "signing_transaction_please_wait".tr);
    final signRequest = WalletSigningRequest(
      addresses: [address],
      network: network,
      sign: (generateSignature) async {
        final signRequest = CosmosSigningRequest(
            digest: digest, index: address.keyIndex, alg: address.algorithm);
        final response = await generateSignature(signRequest);
        return response.signature;
      },
    );
    final signatures =
        await walletProvider.wallet.signTransaction(request: signRequest);
    if (signatures.hasError) {
      progressKey.error(error: signatures.exception, showBackButton: true);
      return;
    }
    _cancelable.dispose();
    final response = form.buildResponse(signatures.result);
    request.completeResponse(response);
    progressKey.response(text: "transaction_signed".tr);
  }

  @override
  Future<void> initWeb3() async {
    liveRequest.addListener(_onChangeForm);
    form.onCompleteForm = _onCompleteForm;
    final init = await MethodUtils.call(
        () => form.initForm(account: account, address: address));
    if (init.hasError) {
      progressKey.errorResponse(error: init.exception);
      request.error(Web3RequestExceptionConst.fromException(init.exception!));
      return;
    }
    progressKey.idle();
  }

  void _onChangeForm() {
    notify();
  }

  @override
  void close() {
    super.close();
    liveRequest.removeListener(_onChangeForm);
    form.close();
  }
}
