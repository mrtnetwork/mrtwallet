import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/permission.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthreumRequestAccounts extends Web3EthereumPermissionRequestParam {
  Web3EthreumRequestAccounts();

  factory Web3EthreumRequestAccounts.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3EthreumRequestAccounts();
  }

  @override
  Web3EthereumRequestMethods get method =>
      Web3EthereumRequestMethods.requestAccounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  ETHAddress? get account => null;

  @override
  Web3EthereumRequest<Web3EthereumChain, Web3EthreumRequestAccounts> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required EthereumChain chain,
  }) {
    return Web3EthereumRequest<Web3EthereumChain, Web3EthreumRequestAccounts>(
      // permission: authenticated.getChain(address: account, chain: chain) ??
      //     Web3EthereumChain.create(chainId: chain.network.coinParam.chainId),
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
