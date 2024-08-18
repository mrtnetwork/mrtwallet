import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3EthereumChain
    extends Web3Chain<ETHAddress, EthereumChain, Web3EthereumChainAccount> {
  BigInt _currentChain;
  BigInt get currentChain => _currentChain;
  Web3EthereumChain._(
      {required super.accounts,
      required BigInt currentChain,
      required super.activities})
      : _currentChain = currentChain;
  @override
  Web3EthereumChain clone() {
    return Web3EthereumChain._(
        accounts: accounts, currentChain: currentChain, activities: activities);
  }

  factory Web3EthereumChain.create({BigInt? chainId}) {
    return Web3EthereumChain._(
        accounts: const [],
        currentChain: chainId ?? BigInt.one,
        activities: const []);
  }

  @override
  List<Web3EthereumChainAccount> get accounts => super.accounts.cast();

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
        currentChain: values.elementAt(1),
        activities: values
            .elementAt<List<dynamic>>(2)
            .map((e) => Web3AccountAcitvity.deserialize(object: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          _currentChain,
          CborListValue.fixedLength(activities.map((e) => e.toCbor()).toList()),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.ethereum;

  @override
  IEthAddress getAccountPermission(
      {required ETHAddress address, required EthereumChain chain}) {
    try {
      final permissionAccount =
          accounts.firstWhere((e) => e.address == address);
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
  List<Web3EthereumChainAccount> currentChainAccounts(EthereumChain chain) {
    final currentAccounts =
        accounts.where((e) => e.chainId == _currentChain).toList();
    List<Web3EthereumChainAccount> existsAccounts = [];
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
  Web3EthereumChainAccount? getPermission(ETHAddress address) {
    return accounts.firstWhereOrNull((e) => e.address == address);
  }

  void updateChainId(EthereumChain chain) {
    _currentChain = chain.chainId;
  }

  @override
  Web3EthereumChain disconnect() {
    return Web3EthereumChain._(
        accounts: const [], currentChain: currentChain, activities: activities);
  }

  @override
  bool hasPermission(EthereumChain chain) =>
      currentChainAccounts(chain).isNotEmpty;
}
