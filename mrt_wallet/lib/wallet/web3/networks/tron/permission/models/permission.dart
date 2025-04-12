import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/tron.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3TronChain extends Web3Chain<TronAddress, TronChain,
    Web3TronChainAccount, WalletTronNetwork> {
  Web3TronChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.tron);
  @override
  Web3TronChain clone() {
    return Web3TronChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3TronChain.create({int? id}) {
    return Web3TronChain._(
        accounts: const [], id: id ?? NetworkType.tron.mainNetworkId);
  }

  @override
  List<Web3TronChainAccount> get activeAccounts => super.activeAccounts.cast();

  factory Web3TronChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: object, tags: NetworkType.tron.tag);
    return Web3TronChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3TronChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3TronChain disconnect() {
    return Web3TronChain._(
        accounts: const [], id: NetworkType.tron.mainNetworkId);
  }

  @override
  Web3TronChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletTronNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());

    final web3Networks = networks.map((e) {
      final tron = APIUtils.findNetworkProvider<TronAPIProvider>(e.network,
          identifier: e.serviceIdentifier, allowInWeb3: true);
      return Web3TronChainIdnetifier(
          id: e.network.value,
          chainId: e.network.tronNetworkType.genesisBlockNumber,
          solidityNode: tron!.solidityProvider.callUrl,
          fullNode: tron.callUrl);
    }).toList();
    final currentWeb3Network =
        web3Networks.firstWhere((e) => e.id == currentNetwork.value);
    return Web3TronChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
