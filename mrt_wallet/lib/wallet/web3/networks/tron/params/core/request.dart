import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/models/sign_message_v2.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/models/switch_chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/models/transaction.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/permission.dart';
import 'package:on_chain/on_chain.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';

abstract class Web3TronRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE, TronAddress, TronChain, Web3TronChainAccount, Web3TronChain> {
  @override
  abstract final Web3TronRequestMethods method;
  @override
  Web3TronChainAccount? get account => null;

  Web3TronRequestParam();

  @override
  Web3TronRequest<RESPONSE, Web3TronRequestParam<RESPONSE>> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final TronChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3TronRequest<RESPONSE, Web3TronRequestParam<RESPONSE>>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  factory Web3TronRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3TronRequestParam param;
    switch (method) {
      case Web3TronRequestMethods.signTransaction:
        param = Web3TronSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3TronRequestMethods.signMessageV2:
        param = Web3TronSignMessageV2.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3TronRequestMethods.switchTronChain:
        param = Web3TronSwitchChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3TronRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3TronRequest<RESPONSE, PARAMS extends Web3TronRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, TronAddress, TronChain,
        Web3TronChainAccount, Web3TronChain, PARAMS> {
  Web3TronRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain});

  Web3TronRequest<R, P> cast<R, P extends Web3TronRequestParam<R>>() {
    return this as Web3TronRequest<R, P>;
  }
}
