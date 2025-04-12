import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'account.dart';

class Web3CosmosChain extends Web3Chain<CosmosBaseAddress, CosmosChain,
    Web3CosmosChainAccount, WalletCosmosNetwork> {
  Web3CosmosChain._({required super.accounts, required super.id})
      : super(network: NetworkType.cosmos);

  @override
  Web3CosmosChain clone() {
    return Web3CosmosChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3CosmosChain.create({int? id}) {
    return Web3CosmosChain._(
        accounts: const [], id: id ?? NetworkType.cosmos.mainNetworkId);
  }

  factory Web3CosmosChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.cosmos.tag);
    return Web3CosmosChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3CosmosChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3CosmosChain disconnect() {
    return Web3CosmosChain._(
      accounts: const [],
      id: NetworkType.cosmos.mainNetworkId,
    );
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletCosmosNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3CosmoshainIdnetifier(
            id: e.network.value, chainId: e.network.coinParam.chainId))
        .toList();
    final currentWeb3Network = Web3CosmoshainIdnetifier(
        id: currentNetwork.value, chainId: currentNetwork.coinParam.chainId);
    return Web3CosmosChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
