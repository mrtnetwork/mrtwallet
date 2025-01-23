import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/network/params/solana.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3SolanaChain extends Web3Chain<SolAddress, SolanaChain,
    Web3SolanaChainAccount, WalletSolanaNetwork> {
  SolanaNetworkType _genesis;
  SolanaNetworkType get currentChain => _genesis;
  Web3SolanaChain._(
      {required super.accounts,
      required SolanaNetworkType genesis,
      required super.activities})
      : _genesis = genesis;
  @override
  Web3SolanaChain clone() {
    return Web3SolanaChain._(
        accounts: activeAccounts,
        genesis: SolanaNetworkType.mainnet,
        activities: activities);
  }

  factory Web3SolanaChain.create({SolanaNetworkType? genesisBlock}) {
    return Web3SolanaChain._(
        accounts: const [],
        genesis: genesisBlock ?? SolanaNetworkType.mainnet,
        activities: const []);
  }

  @override
  List<Web3SolanaChainAccount> get activeAccounts =>
      super.activeAccounts.cast();

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
        genesis: SolanaNetworkType.fromValue(values.elementAt(1)),
        activities: values
            .elementAt<List<dynamic>>(2)
            .map((e) => Web3AccountAcitvity.deserialize(object: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              activeAccounts.map((e) => e.toCbor()).toList()),
          _genesis.value,
          CborListValue.fixedLength(activities.map((e) => e.toCbor()).toList()),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.solana;

  @override
  ISolanaAddress getAccountPermission(
      {required SolAddress address, required SolanaChain chain}) {
    try {
      final permissionAccount = activeAccounts.firstWhere((e) =>
          e.address == address && e.genesis == chain.network.coinParam.type);
      final chainAccount = chain.addresses.firstWhere((e) {
        return e.networkAddress == permissionAccount.address &&
            e.keyIndex == permissionAccount.keyIndex;
      });
      return chainAccount;
    } on StateError {
      throw Web3RequestExceptionConst.missingPermission;
    }
  }

  @override
  Web3SolanaChainAccount? getPermission(SolAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(WalletSolanaNetwork network) {
    _genesis = network.coinParam.type;
  }

  @override
  Web3SolanaChain disconnect() {
    return Web3SolanaChain._(
        accounts: const [],
        genesis: SolanaNetworkType.mainnet,
        activities: activities);
  }

  @override
  List<Web3SolanaChainAccount> chainAccounts(SolanaChain chain) {
    final currentAccounts = activeAccounts
        .where((e) => e.genesis == chain.network.coinParam.type)
        .toList();
    final List<Web3SolanaChainAccount> existsAccounts = [];
    for (final i in chain.addresses) {
      final chainAccount = currentAccounts.firstWhereOrNull(
          (e) => e.addressStr == i.address.address && e.keyIndex == i.keyIndex);
      if (chainAccount != null) {
        existsAccounts.add(chainAccount);
      }
    }
    return existsAccounts;
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletSolanaNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final network = networks.firstWhere(
        (e) => e.network.coinParam.type == currentNetwork.coinParam.type,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
    final currentAccounts = activeAccounts
        .where((e) => e.genesis == currentNetwork.coinParam.type)
        .toList();
    return Web3SolanaChainAuthenticated(
        accounts: currentAccounts,
        network: network.network,
        serviceIdentifier: network.serviceIdentifier);
  }

  @override
  SolanaChain getCurrentPermissionChain(List<SolanaChain> chain) {
    final currentNetwork =
        getCurrentPermissionNetwork(chain.map((e) => e.network).toList());
    List<Web3SolanaChainAccount> accounts = activeAccounts.clone();

    List<Web3SolanaChainAccount> existsAccount = [];
    for (final i in accounts) {
      final network =
          chain.firstWhereOrNull((e) => e.network.coinParam.type == i.genesis);
      if (network == null) continue;
      final exist = network.addresses.any((e) => e.networkAddress == i.address);
      if (exist) existsAccount.add(i);
    }
    updateChainAccount(existsAccount);
    return chain.firstWhere((e) => e.network == currentNetwork);
  }

  @override
  WalletSolanaNetwork getCurrentPermissionNetwork(
      List<WalletSolanaNetwork> networks) {
    final currentChain = _genesis;
    final network =
        networks.firstWhereOrNull((e) => e.coinParam.type == currentChain);
    if (network != null) {
      return network;
    }
    final mainNetwork = networks
        .firstWhere((e) => e.coinParam.type == SolanaNetworkType.mainnet);
    List<Web3SolanaChainAccount> accounts =
        activeAccounts.clone().where((e) => e.genesis != currentChain).toList();
    setActiveChain(mainNetwork);
    updateChainAccount(accounts);
    return mainNetwork;
  }
}
