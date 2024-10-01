import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/permission/permission.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarRequestAccounts extends Web3StellarPermissionRequestParam {
  Web3StellarRequestAccounts();

  factory Web3StellarRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3StellarRequestAccounts();
  }

  @override
  Web3StellarRequestMethods get method =>
      Web3StellarRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  StellarAddress? get account => null;

  @override
  Web3StellarRequest<Web3StellarChain, Web3StellarRequestAccounts> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required StellarChain chain,
  }) {
    return Web3StellarRequest<Web3StellarChain, Web3StellarRequestAccounts>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
