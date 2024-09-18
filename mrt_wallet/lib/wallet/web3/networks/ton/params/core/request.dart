import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/params.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/permission/models/permission.dart';
import 'package:ton_dart/ton_dart.dart';

abstract class Web3TonPermissionRequestParam
    extends Web3TonRequestParam<Web3TonChain>
    implements
        Web3PermissionRequest<TonAddress, TheOpenNetworkChain,
            Web3TonChainAccount, Web3TonChain> {
  @override
  bool get isPermissionRequest => true;
  @override
  Object? toJsWalletResponse(Web3TonChain response) {
    return null;
  }
}

abstract class Web3TonRequestParam<RESPONSE> extends Web3RequestParams<RESPONSE,
    TonAddress, TheOpenNetworkChain, Web3TonChainAccount, Web3TonChain> {
  @override
  abstract final Web3TonRequestMethods method;
  @override
  abstract final TonAddress? account;

  Web3TonRequestParam();

  @override
  Web3TonRequest<RESPONSE, Web3TonRequestParam<RESPONSE>> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required TheOpenNetworkChain chain}) {
    return Web3TonRequest<RESPONSE, Web3TonRequestParam<RESPONSE>>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  factory Web3TonRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3RequestMethods.fromTag(values.elementAt(0));
    final Web3TonRequestParam param;
    switch (method) {
      case Web3TonRequestMethods.requestAccounts:
        param = Web3TonRequestAccounts.deserialize(
            bytes: bytes, object: object, hex: hex);
      case Web3TonRequestMethods.sendTransaction:
        param = Web3TonSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
      case Web3TonRequestMethods.signMessage:
        param = Web3TonSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3TonRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3TonRequest<RESPONSE, PARAMS extends Web3TonRequestParam<RESPONSE>>
    extends Web3Request<RESPONSE, TonAddress, TheOpenNetworkChain,
        Web3TonChainAccount, Web3TonChain, PARAMS> {
  Web3TonRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain});

  Web3TonRequest<R, P> cast<R, P extends Web3TonRequestParam<R>>() {
    return this as Web3TonRequest<R, P>;
  }

  @override
  Web3TonChain? get currentPermission =>
      authenticated.getChainFromNetworkType(chain.network.type);

  @override
  ITonAddress? accountPermission() {
    if (params.account == null) {
      return null;
    }
    if (currentPermission == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return currentPermission!
        .getAccountPermission(address: params.account!, chain: chain);
  }
}
