import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/permission/models/permission.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaRequestAccounts extends Web3SolanaPermissionRequestParam {
  Web3SolanaRequestAccounts();

  factory Web3SolanaRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SolanaRequestAccounts();
  }

  @override
  Web3SolanaRequestMethods get method =>
      Web3SolanaRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  SolAddress? get account => null;

  @override
  Web3SolanaRequest<Web3SolanaChain, Web3SolanaRequestAccounts> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required SolanaChain chain,
  }) {
    return Web3SolanaRequest<Web3SolanaChain, Web3SolanaRequestAccounts>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
