import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'account.dart';

class Web3SubstrateChain extends Web3Chain<BaseSubstrateAddress, SubstrateChain,
    Web3SubstrateChainAccount, WalletSubstrateNetwork> {
  Web3SubstrateChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.substrate);
  @override
  Web3SubstrateChain clone() {
    return Web3SubstrateChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3SubstrateChain.create({int? id}) {
    return Web3SubstrateChain._(
        accounts: const [], id: id ?? NetworkType.substrate.mainNetworkId);
  }

  factory Web3SubstrateChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.substrate.tag);
    return Web3SubstrateChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3SubstrateChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3SubstrateChain disconnect() {
    return Web3SubstrateChain._(
      accounts: const [],
      id: NetworkType.substrate.mainNetworkId,
    );
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletSubstrateNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3SubstrateChainIdnetifier(
              genesisHash: e.network.genesisBlock,
              specVersion: e.network.coinParam.specVersion,
              id: e.network.value,
            ))
        .toList();
    final currentWeb3Network = Web3SubstrateChainIdnetifier(
      genesisHash: currentNetwork.genesisBlock,
      specVersion: currentNetwork.coinParam.specVersion,
      id: currentNetwork.value,
    );
    return Web3SubstrateChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
