import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/permission/models/permission.dart';
import 'package:on_chain/aptos/aptos.dart';

class Web3AptosRequestAccounts extends Web3AptosPermissionRequestParam {
  Web3AptosRequestAccounts();

  factory Web3AptosRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3AptosRequestAccounts();
  }

  @override
  Web3AptosRequestMethods get method => Web3AptosRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  AptosAddress? get account => null;

  @override
  Web3AptosRequest<Web3AptosChain, Web3AptosRequestAccounts> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required List<APPCHAIN> chains,
  }) {
    final AptosChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3AptosRequest<Web3AptosChain, Web3AptosRequestAccounts>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
