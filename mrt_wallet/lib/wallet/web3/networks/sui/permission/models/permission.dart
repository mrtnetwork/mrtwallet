import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/chain/const.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3SuiChain extends Web3Chain<SuiAddress, SuiChain, Web3SuiChainAccount,
    WalletSuiNetwork> {
  int _id;
  @override
  int get currentChain => _id;
  Web3SuiChain._(
      {required super.accounts, required int id, required super.activities})
      : _id = id;
  @override
  Web3SuiChain clone() {
    return Web3SuiChain._(
        accounts: activeAccounts,
        id: ChainConst.suiMainnetId,
        activities: activities);
  }

  factory Web3SuiChain.create({int? id}) {
    return Web3SuiChain._(
        accounts: const [],
        id: id ?? ChainConst.suiMainnetId,
        activities: const []);
  }

  @override
  List<Web3SuiChainAccount> get activeAccounts => super.activeAccounts.cast();

  factory Web3SuiChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: object, tags: NetworkType.sui.tag);
    return Web3SuiChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3SuiChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1),
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
          currentChain,
          CborListValue.fixedLength(activities.map((e) => e.toCbor()).toList()),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.sui;

  @override
  ISuiAddress getAccountPermission(
      {required SuiAddress address, required SuiChain chain}) {
    try {
      final permissionAccount = activeAccounts.firstWhere(
          (e) => e.address == address && e.id == chain.network.value);
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
  Web3SuiChainAccount? getPermission(SuiAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(WalletSuiNetwork network) {
    _id = network.value;
  }

  @override
  Web3SuiChain disconnect() {
    return Web3SuiChain._(
        accounts: const [],
        id: ChainConst.suiMainnetId,
        activities: activities);
  }

  @override
  List<Web3SuiChainAccount> chainAccounts(SuiChain chain) {
    final currentAccounts =
        activeAccounts.where((e) => e.id == chain.network.value).toList();
    final List<Web3SuiChainAccount> existsAccounts = [];
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
      List<Web3ChainNetworkData<WalletSuiNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final network = networks.firstWhere(
        (e) =>
            e.network.coinParam.suiChain == currentNetwork.coinParam.suiChain,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
    final currentAccounts =
        activeAccounts.where((e) => e.id == currentNetwork.value).toList();
    return Web3SuiChainAuthenticated(
        accounts: currentAccounts,
        network: network.network,
        serviceIdentifier: network.serviceIdentifier);
  }

  @override
  SuiChain getCurrentPermissionChain(List<SuiChain> chain) {
    final currentNetwork =
        getCurrentPermissionNetwork(chain.map((e) => e.network).toList());
    List<Web3SuiChainAccount> accounts = activeAccounts.clone();

    List<Web3SuiChainAccount> existsAccount = [];
    for (final i in accounts) {
      final network = chain.firstWhereOrNull((e) => e.network.value == i.id);
      if (network == null) continue;
      final exist = network.addresses.any((e) => e.networkAddress == i.address);
      if (exist) existsAccount.add(i);
    }
    updateChainAccount(existsAccount);
    return chain.firstWhere(
      (e) => e.network == currentNetwork,
      orElse: () => throw Web3RequestExceptionConst.networkDoesNotExists,
    );
  }

  @override
  WalletSuiNetwork getCurrentPermissionNetwork(
      List<WalletSuiNetwork> networks) {
    final currentChain = this.currentChain;
    final network = networks.firstWhereOrNull((e) => e.value == currentChain);
    if (network != null) {
      return network;
    }
    final mainNetwork =
        networks.firstWhere((e) => e.value == ChainConst.suiMainnetId);
    List<Web3SuiChainAccount> accounts =
        activeAccounts.clone().where((e) => e.id != currentChain).toList();
    setActiveChain(mainNetwork);
    updateChainAccount(accounts);
    return mainNetwork;
  }
}
