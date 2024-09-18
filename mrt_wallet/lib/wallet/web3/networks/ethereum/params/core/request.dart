import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/requests.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/permission.dart';

import 'package:on_chain/ethereum/src/address/evm_address.dart';

abstract class Web3EthereumPermissionRequestParam
    extends Web3EthereumRequestParam<Web3EthereumChain>
    implements
        Web3PermissionRequest<ETHAddress, EthereumChain,
            Web3EthereumChainAccount, Web3EthereumChain> {
  @override
  bool get isPermissionRequest => true;
  @override
  Object? toJsWalletResponse(Web3EthereumChain response) {
    return null;
  }
}

abstract class Web3EthereumRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    ETHAddress,
    EthereumChain,
    Web3EthereumChainAccount,
    Web3EthereumChain> {
  @override
  abstract final Web3EthereumRequestMethods method;
  @override
  abstract final ETHAddress? account;

  Web3EthereumRequestParam();

  @override
  Web3EthereumRequest<RESPONSE, Web3EthereumRequestParam<RESPONSE>> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required EthereumChain chain,
  }) {
    return Web3EthereumRequest<RESPONSE, Web3EthereumRequestParam<RESPONSE>>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }

  factory Web3EthereumRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3RequestMethods.fromTag(values.elementAt(0));
    final Web3EthereumRequestParam param;
    switch (method) {
      case Web3EthereumRequestMethods.addEthereumChain:
        param = Web3EthereumAddNewChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.persoalSign:
        param = Web3EthreumPersonalSign.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.requestAccounts:
        param = Web3EthreumRequestAccounts.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.sendTransaction:
        param = Web3EthreumSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.typedData:
        param = Web3EthreumTypdedData.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.switchEthereumChain:
        param = Web3EthreumSwitchChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3EthereumRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3EthereumRequest<RESPONSE,
        PARAMS extends Web3EthereumRequestParam<RESPONSE>>
    extends Web3Request<RESPONSE, ETHAddress, EthereumChain,
        Web3EthereumChainAccount, Web3EthereumChain, PARAMS> {
  Web3EthereumRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain});

  @override
  Web3EthereumChain? get currentPermission =>
      authenticated.getChainFromNetworkType(chain.network.type);

  @override
  IEthAddress? accountPermission() {
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
