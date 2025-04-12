import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/params/models/sign_message.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/params/models/transaction.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/permission/models/permission.dart';
import 'package:on_chain/sui/src/address/address/address.dart';

abstract class Web3SuiRequestParam<RESPONSE> extends Web3RequestParams<RESPONSE,
    SuiAddress, SuiChain, Web3SuiChainAccount, Web3SuiChain> {
  @override
  abstract final Web3SuiRequestMethods method;
  @override
  Web3SuiChainAccount? get account => null;

  Web3SuiRequestParam();

  @override
  Web3SuiRequest<RESPONSE, Web3SuiRequestParam<RESPONSE>> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final SuiChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SuiRequest<RESPONSE, Web3SuiRequestParam<RESPONSE>>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }

  factory Web3SuiRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3SuiRequestParam param;
    switch (method) {
      case Web3SuiRequestMethods.signTransaction:
      case Web3SuiRequestMethods.signTransactionBlock:
      case Web3SuiRequestMethods.signAndExecuteTransaction:
      case Web3SuiRequestMethods.signAndExecuteTransactionBlock:
        param = Web3SuiSignOrExecuteTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
        param = Web3SuiSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3SuiRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3SuiRequest<RESPONSE, PARAMS extends Web3SuiRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, SuiAddress, SuiChain,
        Web3SuiChainAccount, Web3SuiChain, PARAMS> {
  Web3SuiRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain});

  Web3SuiRequest<R, P> cast<R, P extends Web3SuiRequestParam<R>>() {
    return this as Web3SuiRequest<R, P>;
  }
}
