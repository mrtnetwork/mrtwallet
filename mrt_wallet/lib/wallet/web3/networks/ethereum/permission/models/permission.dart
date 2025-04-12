import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3EthereumChain extends Web3Chain<ETHAddress, EthereumChain,
    Web3EthereumChainAccount, WalletEthereumNetwork> {
  Web3EthereumChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.ethereum);

  @override
  Web3EthereumChain clone() {
    return Web3EthereumChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3EthereumChain.create({int? id}) {
    return Web3EthereumChain._(
        accounts: const [], id: id ?? NetworkType.ethereum.mainNetworkId);
  }

  factory Web3EthereumChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.ethereum.tag);
    return Web3EthereumChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3EthereumChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3EthereumChain disconnect() {
    return Web3EthereumChain._(
        accounts: const [], id: NetworkType.ethereum.mainNetworkId);
  }

  @override
  Web3EthereumChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletEthereumNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3EthereumChainIdnetifier(
              id: e.network.value,
              chainId: e.network.coinParam.chainId,
              supportEIP1559: e.network.coinParam.supportEIP1559,
            ))
        .toList();
    final currentWeb3Network = Web3EthereumChainIdnetifier(
        id: currentNetwork.value,
        chainId: currentNetwork.coinParam.chainId,
        supportEIP1559: currentNetwork.coinParam.supportEIP1559);
    final network =
        networks.firstWhere((e) => e.network.value == currentNetwork.value);
    final provider = APIUtils.findNetworkProvider<EthereumAPIProvider>(
        network.network,
        identifier: network.serviceIdentifier,
        allowInWeb3: true);
    return Web3EthereumChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network,
        serviceIdentifier: provider);
  }
}
