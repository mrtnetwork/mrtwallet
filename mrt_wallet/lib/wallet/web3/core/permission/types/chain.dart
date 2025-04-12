import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/permission.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/tron.dart';
import 'account.dart';

typedef Web3ChainNetwork<NETWORKADDRESS> = Web3Chain<
    NETWORKADDRESS,
    APPCHAINNETWORK<NETWORKADDRESS>,
    Web3ChainAccount<NETWORKADDRESS>,
    WalletNetwork>;

abstract class Web3Chain<
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    CHAINACCOUT extends Web3ChainAccount<NETWORKADDRESS>,
    NETWORK extends WalletNetwork> with CborSerializable, Equatable {
  Web3Chain(
      {required List<CHAINACCOUT> accounts,
      required this.network,
      required int id})
      : _accounts = accounts.imutable,
        _id = id;

  factory Web3Chain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final network = NetworkType.fromTag(decode.tags);
    Web3Chain chain;
    switch (network) {
      case NetworkType.ethereum:
        chain = Web3EthereumChain.deserialize(object: decode);
        break;
      case NetworkType.tron:
        chain = Web3TronChain.deserialize(object: decode);
        break;
      case NetworkType.solana:
        chain = Web3SolanaChain.deserialize(object: decode);
        break;
      case NetworkType.ton:
        chain = Web3TonChain.deserialize(object: decode);
        break;
      case NetworkType.stellar:
        chain = Web3StellarChain.deserialize(object: decode);
        break;
      case NetworkType.substrate:
        chain = Web3SubstrateChain.deserialize(object: decode);
        break;
      case NetworkType.aptos:
        chain = Web3AptosChain.deserialize(object: decode);
        break;
      case NetworkType.sui:
        chain = Web3SuiChain.deserialize(object: decode);
        break;
      case NetworkType.cosmos:
        chain = Web3CosmosChain.deserialize(object: decode);
        break;
      case NetworkType.bitcoinAndForked:
        chain = Web3BitcoinChain.deserialize(object: decode);
        break;
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
    if (chain is! Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUT, NETWORK>) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return chain;
  }

  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<NETWORK>> networks);
  Web3Chain clone();
  Web3Chain disconnect();
  final NetworkType network;
  int _id;
  int get currentChain => _id;
  List<CHAINACCOUT> _accounts;
  List<CHAINACCOUT> get activeAccounts => _accounts.cast();

  bool get hasAccount => _accounts.isNotEmpty;

  List<CHAINACCOUT> chainAccounts(CHAIN chain) {
    final currentAccounts =
        activeAccounts.where((e) => e.id == chain.network.value).toList();
    final List<CHAINACCOUT> existsAccounts = [];
    for (final i in chain.addresses) {
      final chainAccount = currentAccounts.firstWhereOrNull(
          (e) => e.addressStr == i.address.address && e.keyIndex == i.keyIndex);
      if (chainAccount != null) {
        existsAccounts.add(chainAccount);
      }
    }
    return existsAccounts;
  }

  CHAIN getCurrentPermissionChain(List<CHAIN> chain, CHAINACCOUT? account) {
    final currentNetwork = getCurrentPermissionNetwork(
        chain.map((e) => e.network).toList().cast<NETWORK>(), account);
    if (account != null && currentNetwork.value != account.id) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return chain.firstWhere((e) => e.network.value == currentNetwork.value,
        orElse: () => throw Web3RequestExceptionConst.networkDoesNotExists);
  }

  NETWORK getCurrentPermissionNetwork(List<NETWORK> networks,
      [CHAINACCOUT? account]) {
    final existsNetworks = networks.map((e) => e.value);
    final validAccoutnts =
        _accounts.where((e) => existsNetworks.contains(e.id)).toList();
    updateChainAccount(validAccoutnts);
    NETWORK? network;
    if (account != null && existsNetworks.contains(account.id)) {
      network = networks.firstWhere((e) => e.value == account.id);
    } else if (existsNetworks.contains(this.currentChain)) {
      network = networks.firstWhere((e) => e.value == currentChain);
    }
    if (network != null) {
      return network;
    }
    final mainNetwork =
        networks.firstWhere((e) => e.value == this.network.mainNetworkId);
    setActiveChain(mainNetwork);
    return mainNetwork;
  }

  bool chainHasPermission(CHAIN chain) => chainAccounts(chain).isNotEmpty;

  NETWORKACCOUNT getAccountPermission<
          NETWORKACCOUNT extends NETWORKCHAINACCOUNT<NETWORKADDRESS>>(
      {required CHAINACCOUT account, required CHAIN chain}) {
    if (!_accounts.contains(account)) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    final chainAccount = chain.getAddress(account.addressStr);
    if (chainAccount == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return chainAccount.cast();
  }

  CHAINACCOUT? getAddressPermission(NETWORKADDRESS address) {
    return _accounts.firstWhereNullable((e) => e.address == address);
  }

  void updateChainAccount(List<CHAINACCOUT> updatedAccounts) {
    final sortedAccounts = updatedAccounts.clone();
    sortedAccounts.sort((a, b) => a.addressStr.compareTo(b.addressStr));
    _accounts = sortedAccounts.imutable;
  }

  void setActiveChain(NETWORK network) {
    _id = network.value;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              activeAccounts.map((e) => e.toCbor()).toList()),
          currentChain
        ]),
        network.tag);
  }

  @override
  List get variabels => [_accounts, currentChain, network];
}
