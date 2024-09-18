import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/permission/permission.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonRequestAccounts extends Web3TonPermissionRequestParam {
  Web3TonRequestAccounts();

  factory Web3TonRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3TonRequestAccounts();
  }

  @override
  Web3TonRequestMethods get method => Web3TonRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  TonAddress? get account => null;

  @override
  Web3TonRequest<Web3TonChain, Web3TonRequestAccounts> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required TheOpenNetworkChain chain,
  }) {
    return Web3TonRequest<Web3TonChain, Web3TonRequestAccounts>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
