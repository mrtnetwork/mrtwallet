import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:ton_dart/ton_dart.dart';
import 'account.dart';

class Web3TonChain extends Web3Chain<TonAddress, TheOpenNetworkChain,
    Web3TonChainAccount, WalletTonNetwork> {
  int _id;
  @override
  int get currentChain => _id;
  Web3TonChain._(
      {required super.accounts, required int id, required super.activities})
      : _id = id;
  @override
  Web3TonChain clone() {
    return Web3TonChain._(
        accounts: activeAccounts,
        id: ChainConst.tonMainnetId,
        activities: activities);
  }

  factory Web3TonChain.create({int? id}) {
    return Web3TonChain._(
        accounts: const [],
        id: id ?? ChainConst.tonMainnetId,
        activities: const []);
  }

  @override
  List<Web3TonChainAccount> get activeAccounts => super.activeAccounts.cast();

  factory Web3TonChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: object, tags: NetworkType.ton.tag);
    return Web3TonChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3TonChainAccount.deserialize(object: e))
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
          _id,
          CborListValue.fixedLength(activities.map((e) => e.toCbor()).toList()),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.ton;

  @override
  ITonAddress getAccountPermission(
      {required TonAddress address, required TheOpenNetworkChain chain}) {
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
  Web3TonChainAccount? getPermission(TonAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(WalletTonNetwork network) {
    _id = network.value;
  }

  @override
  Web3TonChain disconnect() {
    return Web3TonChain._(
        accounts: const [],
        id: ChainConst.tonMainnetId,
        activities: activities);
  }

  @override
  List<Web3TonChainAccount> chainAccounts(TheOpenNetworkChain chain) {
    final currentAccounts =
        activeAccounts.where((e) => e.id == chain.network.value).toList();
    final List<Web3TonChainAccount> existsAccounts = [];
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
      List<Web3ChainNetworkData<WalletTonNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final network = networks.firstWhere(
        (e) => e.network.value == currentNetwork.value,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
    final currentAccounts =
        activeAccounts.where((e) => e.id == currentNetwork.value).toList();
    return Web3TonChainAuthenticated(
        accounts: currentAccounts,
        network: network.network,
        serviceIdentifier: network.serviceIdentifier);
  }

  @override
  TheOpenNetworkChain getCurrentPermissionChain(
      List<TheOpenNetworkChain> chain) {
    final currentNetwork =
        getCurrentPermissionNetwork(chain.map((e) => e.network).toList());
    List<Web3TonChainAccount> accounts = activeAccounts.clone();
    List<Web3TonChainAccount> existsAccount = [];
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
  WalletTonNetwork getCurrentPermissionNetwork(
      List<WalletTonNetwork> networks) {
    final currentChain = _id;
    final network = networks.firstWhereOrNull((e) => e.value == currentChain);
    if (network != null) {
      return network;
    }
    final mainNetwork =
        networks.firstWhere((e) => e.value == ChainConst.tonMainnetId);
    List<Web3TonChainAccount> accounts =
        activeAccounts.clone().where((e) => e.id != currentChain).toList();
    setActiveChain(mainNetwork);
    updateChainAccount(accounts);
    return mainNetwork;
  }
}
