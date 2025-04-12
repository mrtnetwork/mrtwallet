import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:ton_dart/ton_dart.dart';
import 'account.dart';

class Web3TonChain extends Web3Chain<TonAddress, TheOpenNetworkChain,
    Web3TonChainAccount, WalletTonNetwork> {
  Web3TonChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.ton);
  @override
  Web3TonChain clone() {
    return Web3TonChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3TonChain.create({int? id}) {
    return Web3TonChain._(
        accounts: const [], id: id ?? NetworkType.ton.mainNetworkId);
  }

  factory Web3TonChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: object, tags: NetworkType.ton.tag);
    return Web3TonChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3TonChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3TonChain disconnect() {
    return Web3TonChain._(
        accounts: const [], id: NetworkType.ton.mainNetworkId);
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletTonNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());

    final web3Networks = networks
        .map((e) => Web3ChainDefaultIdnetifier(
            id: e.network.value,
            identifier: e.network.coinParam.tonChainIdentifier))
        .toList();
    final currentWeb3Network = Web3ChainDefaultIdnetifier(
        id: currentNetwork.value,
        identifier: currentNetwork.coinParam.tonChainIdentifier);
    return Web3TonChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
