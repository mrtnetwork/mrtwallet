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

class Web3SolanaChain extends Web3Chain<SolAddress, SolanaChain,
    Web3SolanaChainAccount, WalletSolanaNetwork> {
  Web3SolanaChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.solana);
  @override
  Web3SolanaChain clone() {
    return Web3SolanaChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3SolanaChain.create({int? id}) {
    return Web3SolanaChain._(
        accounts: const [], id: id ?? NetworkType.solana.mainNetworkId);
  }

  factory Web3SolanaChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.solana.tag);
    return Web3SolanaChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3SolanaChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3SolanaChain disconnect() {
    return Web3SolanaChain._(
      accounts: const [],
      id: NetworkType.solana.mainNetworkId,
    );
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletSolanaNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3ChainDefaultIdnetifier(
            id: e.network.value,
            identifier: e.network.coinParam.type.identifier))
        .toList();
    final currentWeb3Network = Web3ChainDefaultIdnetifier(
        id: currentNetwork.value,
        identifier: currentNetwork.coinParam.type.identifier);
    return Web3SolanaChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
