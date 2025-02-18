import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/permission/models/permission.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class Web3SubstrateRequestAccounts extends Web3SubstratePermissionRequestParam {
  Web3SubstrateRequestAccounts();

  factory Web3SubstrateRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SubstrateRequestAccounts();
  }

  @override
  Web3SubstrateRequestMethods get method =>
      Web3SubstrateRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  BaseSubstrateAddress? get account => null;

  @override
  Web3SubstrateRequest<Web3SubstrateChain, Web3SubstrateRequestAccounts>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final SubstrateChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SubstrateRequest<Web3SubstrateChain,
            Web3SubstrateRequestAccounts>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
