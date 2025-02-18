import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/aptos/forms/core/aptos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/aptos/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';

class Web3AptosSignMessageForm extends AptosWeb3Form<Web3AptosSignMessage> {
  Web3AptosSignMessageForm({required this.request});

  late final String? content;
  late final String message;
  late final List<int> payloadMessage;
  String? _address;
  String? _application;
  int? _chainId;
  bool get isAptosSiningRequest => request.params.message != null;

  Web3AptosSignMessageResponse buildResponse(List<int> signature) {
    switch (isAptosSiningRequest) {
      case true:
        return Web3AptosSignMessageResponse.aptos(
            message: request.params.message!,
            nonce: request.params.nonce!,
            fullMessage: message,
            prefix: Web3AptosConst.signMessagePrefix,
            signature: signature,
            address: _address,
            application: _application,
            chainId: _chainId);
      case false:
        return Web3AptosSignMessageResponse.wallet(signature: signature);
    }
  }

  @override
  Web3AptosRequest<dynamic, Web3AptosSignMessage> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(true);
  }

  @override
  void initForm(
      {required AptosChain account, required IAptosAddress? address}) {
    final signingRequest = request.params;

    if (signingRequest.messageBytes != null) {
      message = signingRequest.messageBytes!;
      payloadMessage = BytesUtils.fromHexString(message).asImmutableBytes;
      content = StringUtils.tryDecode(payloadMessage);
      return;
    }
    String signingMessage = Web3AptosConst.signMessagePrefix;
    if (signingRequest.application ?? false) {
      signingMessage += APPConst.name;
      _application = APPConst.name;
    }
    if (signingRequest.address ?? false) {
      signingMessage += signingRequest.account.address;
      _address = signingRequest.account.address;
    }
    signingMessage += signingRequest.nonce!;
    if (signingRequest.chainId ?? false) {
      signingMessage +=
          account.network.coinParam.aptosChainType.chainId.toString();
      _chainId = account.network.coinParam.aptosChainType.chainId;
    }
    signingMessage += signingRequest.message!;
    message = signingMessage;
    payloadMessage = StringUtils.encode(message).asImmutableBytes;
    content = null;
  }
}
