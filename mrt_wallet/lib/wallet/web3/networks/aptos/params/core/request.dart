import 'package:mrt_wallet/wallet/web3/networks/aptos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/models/sign_message.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/models/switch_chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/models/transaction.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/permission/permission.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:on_chain/aptos/aptos.dart';

abstract class Web3AptosRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE, AptosAddress, AptosChain, Web3AptosChainAccount, Web3AptosChain> {
  @override
  abstract final Web3AptosRequestMethods method;
  @override
  Web3AptosChainAccount? get account => null;
  Web3AptosRequestParam();
  @override
  Web3AptosRequest<RESPONSE, Web3AptosRequestParam<RESPONSE>> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final AptosChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3AptosRequest<RESPONSE, Web3AptosRequestParam<RESPONSE>>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  factory Web3AptosRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3AptosRequestParam param;
    switch (method) {
      case Web3AptosRequestMethods.signTransaction:
      case Web3AptosRequestMethods.signAllTransactions:
      case Web3AptosRequestMethods.sendTransaction:
        param = Web3AptosSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3AptosRequestMethods.signMessage:
        param = Web3AptosSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3AptosRequestMethods.switchNetwork:
        param = Web3AptosSwitchChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;

      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3AptosRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3AptosRequest<RESPONSE, PARAMS extends Web3AptosRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, AptosAddress, AptosChain,
        Web3AptosChainAccount, Web3AptosChain, PARAMS> {
  Web3AptosRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain});

  Web3AptosRequest<R, P> cast<R, P extends Web3AptosRequestParam<R>>() {
    return this as Web3AptosRequest<R, P>;
  }
}
