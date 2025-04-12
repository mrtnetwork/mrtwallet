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

class Web3SuiChain extends Web3Chain<SuiAddress, SuiChain, Web3SuiChainAccount,
    WalletSuiNetwork> {
  Web3SuiChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.sui);
  @override
  Web3SuiChain clone() {
    return Web3SuiChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3SuiChain.create({int? id}) {
    return Web3SuiChain._(
        accounts: const [], id: id ?? NetworkType.sui.mainNetworkId);
  }

  factory Web3SuiChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: object, tags: NetworkType.sui.tag);
    return Web3SuiChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3SuiChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3SuiChain disconnect() {
    return Web3SuiChain._(
        accounts: const [], id: NetworkType.sui.mainNetworkId);
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletSuiNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3ChainDefaultIdnetifier(
            id: e.network.value,
            identifier: e.network.coinParam.suiChain.identifier))
        .toList();
    final currentWeb3Network = Web3ChainDefaultIdnetifier(
        id: currentNetwork.value,
        identifier: currentNetwork.coinParam.suiChain.identifier);
    return Web3SuiChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
