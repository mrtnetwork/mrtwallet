import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/models/add_new_chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/models/sign_message.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/models/switch_chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/permission/models/permission.dart';

import '../models/transaction.dart';

abstract class Web3CosmosRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    CosmosBaseAddress,
    CosmosChain,
    Web3CosmosChainAccount,
    Web3CosmosChain> {
  @override
  abstract final Web3CosmosRequestMethods method;
  @override
  Web3CosmosChainAccount? get account => null;

  Web3CosmosRequestParam();

  @override
  Web3CosmosRequest<RESPONSE, Web3CosmosRequestParam<RESPONSE>> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final CosmosChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3CosmosRequest<RESPONSE, Web3CosmosRequestParam<RESPONSE>>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }

  factory Web3CosmosRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3CosmosRequestParam param;
    switch (method) {
      case Web3CosmosRequestMethods.signTransactionAmino:
      case Web3CosmosRequestMethods.signTransactionDirect:
        param = Web3CosmosSignTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3CosmosRequestMethods.addNewChain:
        param = Web3CosmosAddNewChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3CosmosRequestMethods.signMessage:
        param = Web3CosmosSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3CosmosRequestMethods.switchNetwork:
        param = Web3CosmosSwitchChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
    if (param is! Web3CosmosRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3CosmosRequest<RESPONSE,
        PARAMS extends Web3CosmosRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, CosmosBaseAddress, CosmosChain,
        Web3CosmosChainAccount, Web3CosmosChain, PARAMS> {
  Web3CosmosRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain});

  Web3CosmosRequest<R, P> cast<R, P extends Web3CosmosRequestParam<R>>() {
    return this as Web3CosmosRequest<R, P>;
  }
}
