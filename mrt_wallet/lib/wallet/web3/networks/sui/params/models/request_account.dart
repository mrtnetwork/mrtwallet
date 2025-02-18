import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/permission/models/permission.dart';
import 'package:on_chain/sui/src/address/address/address.dart';

class Web3SuiRequestAccounts extends Web3SuiPermissionRequestParam {
  Web3SuiRequestAccounts();

  factory Web3SuiRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SuiRequestAccounts();
  }

  @override
  Web3SuiRequestMethods get method => Web3SuiRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  SuiAddress? get account => null;

  @override
  Web3SuiRequest<Web3SuiChain, Web3SuiRequestAccounts> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final SuiChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SuiRequest<Web3SuiChain, Web3SuiRequestAccounts>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
