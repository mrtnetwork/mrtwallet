import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/models/sign_message.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/models/transaction.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/permission/permission.dart';
import 'package:stellar_dart/stellar_dart.dart';

abstract class Web3StellarRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    StellarAddress,
    StellarChain,
    Web3StellarChainAccount,
    Web3StellarChain> {
  @override
  abstract final Web3StellarRequestMethods method;
  @override
  Web3StellarChainAccount? get account => null;

  Web3StellarRequestParam();

  @override
  Web3StellarRequest<RESPONSE, Web3StellarRequestParam<RESPONSE>> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final StellarChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3StellarRequest<RESPONSE, Web3StellarRequestParam<RESPONSE>>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  factory Web3StellarRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3StellarRequestParam param;
    switch (method) {
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        param = Web3StellarSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
      case Web3StellarRequestMethods.signMessage:
        param = Web3StellarSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3StellarRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3StellarRequest<RESPONSE,
        PARAMS extends Web3StellarRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, StellarAddress, StellarChain,
        Web3StellarChainAccount, Web3StellarChain, PARAMS> {
  Web3StellarRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain});

  Web3StellarRequest<R, P> cast<R, P extends Web3StellarRequestParam<R>>() {
    return this as Web3StellarRequest<R, P>;
  }
}
