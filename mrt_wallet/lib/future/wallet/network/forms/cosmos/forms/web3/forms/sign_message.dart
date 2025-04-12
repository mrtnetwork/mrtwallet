import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/core/cosmos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3CosmosSignMessageForm extends CosmosWeb3Form<Web3CosmosSignMessage> {
  Web3CosmosSignMessageForm({required this.request});

  @override
  Web3CosmosRequest<Web3CosmosSignMessageResponse, Web3CosmosSignMessage>
      request;
  List<int> challengeBytes() {
    return BytesUtils.fromHexString(request.params.challeng).asImmutableBytes;
  }

  String get message => request.params.challeng;
  String? get content => request.params.content;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(true);
  }

  @override
  Future<void> initForm(
      {required CosmosChain account, required ICosmosAddress? address}) async {
    await super.initForm(account: account, address: address);
    final content = this.content;
    try {
      if (content == null) {
        SignDoc.deserialize(challengeBytes());
      } else {
        final jsonContent = StringUtils.toJson<Map<String, dynamic>>(content);
        AminoTx.fromJson(jsonContent);
      }
      throw Web3RequestExceptionConst.badSignMessage;
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
  }
}
