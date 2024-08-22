import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/permission.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronRequestAccounts extends Web3TronPermissionRequestParam {
  Web3TronRequestAccounts();

  factory Web3TronRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3TronRequestAccounts();
  }

  @override
  Web3TronRequestMethods get method => Web3TronRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  TronAddress? get account => null;

  @override
  Web3TronRequest<Web3TronChain, Web3TronRequestAccounts> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required TronChain chain,
  }) {
    return Web3TronRequest<Web3TronChain, Web3TronRequestAccounts>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
