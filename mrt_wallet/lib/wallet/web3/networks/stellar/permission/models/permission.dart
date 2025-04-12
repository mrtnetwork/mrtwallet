import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'account.dart';

class Web3StellarChain extends Web3Chain<StellarAddress, StellarChain,
    Web3StellarChainAccount, WalletStellarNetwork> {
  Web3StellarChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.stellar);
  @override
  Web3StellarChain clone() {
    return Web3StellarChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3StellarChain.create({int? id}) {
    return Web3StellarChain._(
        accounts: const [], id: id ?? NetworkType.stellar.mainNetworkId);
  }

  factory Web3StellarChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.stellar.tag);
    return Web3StellarChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3StellarChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3StellarChain disconnect() {
    return Web3StellarChain._(
        accounts: const [], id: NetworkType.stellar.mainNetworkId);
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletStellarNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3ChainDefaultIdnetifier(
            id: e.network.value,
            identifier: e.network.coinParam.stellarChainType.identifier))
        .toList();
    final currentWeb3Network = Web3ChainDefaultIdnetifier(
        id: currentNetwork.value,
        identifier: currentNetwork.coinParam.stellarChainType.identifier);
    return Web3StellarChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
