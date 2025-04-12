import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3AptosChain extends Web3Chain<AptosAddress, AptosChain,
    Web3AptosChainAccount, WalletAptosNetwork> {
  Web3AptosChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.aptos);
  @override
  Web3AptosChain clone() {
    return Web3AptosChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3AptosChain.create({int? id}) {
    return Web3AptosChain._(
        accounts: const [], id: id ?? NetworkType.aptos.mainNetworkId);
  }

  factory Web3AptosChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.aptos.tag);
    return Web3AptosChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3AptosChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3AptosChain disconnect() {
    return Web3AptosChain._(
        accounts: const [], id: NetworkType.aptos.mainNetworkId);
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletAptosNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3AptosChainIdnetifier(
            id: e.network.value,
            identifier: e.network.coinParam.aptosChainType.identifier,
            chainId: e.network.coinParam.aptosChainType.id))
        .toList();
    final currentWeb3Network = Web3AptosChainIdnetifier(
        id: currentNetwork.value,
        identifier: currentNetwork.coinParam.aptosChainType.identifier,
        chainId: currentNetwork.coinParam.aptosChainType.id);
    return Web3AptosChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
