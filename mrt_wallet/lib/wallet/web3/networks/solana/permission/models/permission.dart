import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/networks/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3SolanaChain
    extends Web3Chain<SolAddress, SolanaChain, Web3SolanaChainAccount> {
  String _genesis;
  String get currentChain => _genesis;
  Web3SolanaChain._(
      {required super.accounts,
      required String genesis,
      required super.activities})
      : _genesis = genesis;
  @override
  Web3SolanaChain clone() {
    return Web3SolanaChain._(
        accounts: activeAccounts,
        genesis: SolanaConst.mainnetGenesis,
        activities: activities);
  }

  factory Web3SolanaChain.create({String? genesisBlock}) {
    return Web3SolanaChain._(
        accounts: const [],
        genesis: genesisBlock ?? SolanaConst.mainnetGenesis,
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
        genesis: values.elementAt(1),
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
          _genesis,
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
          e.address == address && e.genesis == chain.network.genesisBlock);
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
  void setActiveChain(SolanaChain chain) {
    _genesis = chain.network.genesisBlock;
  }

  @override
  Web3SolanaChain disconnect() {
    return Web3SolanaChain._(
        accounts: const [],
        genesis: SolanaConst.mainnetGenesis,
        activities: activities);
  }

  @override
  List<Web3SolanaChainAccount> chainAccounts(SolanaChain chain) {
    final currentAccounts = activeAccounts
        .where((e) => e.genesis == chain.network.genesisBlock)
        .toList();
    List<Web3SolanaChainAccount> existsAccounts = [];
    for (final i in chain.addresses) {
      final chainAccount = currentAccounts.firstWhereOrNull(
          (e) => e.addressStr == i.address.address && e.keyIndex == i.keyIndex);
      if (chainAccount != null) {
        existsAccounts.add(chainAccount);
      }
    }
    return existsAccounts;
  }
}
