import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/core/request/web_request.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/permission/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/permission/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/models/permission.dart';

class Web3APPAuthentication with CborSerializable {
  final String applicationId;
  final String applicationKey;
  String _name;
  final APPImage? icon;
  bool _active;
  bool get active => _active;
  final List<int> token;
  String get name => _name;
  Map<NetworkType, Web3Chain> _chains;
  List<Web3AccountAcitvity> _activities;
  List<Web3AccountAcitvity> get activities => _activities;

  Web3APPData createAuth(List<Web3ChainNetworkData> networks,
      {List<NetworkType>? web3Networks}) {
    List<Web3ChainAuthenticated> auths = [];
    web3Networks = (web3Networks ??= Web3Const.supportedWeb3).clone();
    for (final i in web3Networks) {
      final web3Chain = getChainFromNetworkType(i);
      List<Web3ChainNetworkData> relatedChains;
      if (i.isBitcoin) {
        relatedChains =
            networks.where((e) => e.network.type.isBitcoin).toList();
      } else {
        relatedChains = networks.where((e) => e.network.type == i).toList();
      }
      if (web3Chain == null || relatedChains.isEmpty) continue;

      switch (i) {
        case NetworkType.ethereum:
          auths.add(web3Chain.createAuthenticated(relatedChains
              .cast<Web3ChainNetworkData<WalletEthereumNetwork>>()));
          break;
        case NetworkType.solana:
          auths.add(web3Chain.createAuthenticated(
              relatedChains.cast<Web3ChainNetworkData<WalletSolanaNetwork>>()));
          break;
        case NetworkType.stellar:
          auths.add(web3Chain.createAuthenticated(relatedChains
              .cast<Web3ChainNetworkData<WalletStellarNetwork>>()));
          break;
        case NetworkType.ton:
          auths.add(web3Chain.createAuthenticated(
              relatedChains.cast<Web3ChainNetworkData<WalletTonNetwork>>()));
          break;
        case NetworkType.tron:
          auths.add(web3Chain.createAuthenticated(
              relatedChains.cast<Web3ChainNetworkData<WalletTronNetwork>>()));
          break;
        case NetworkType.substrate:
          auths.add(web3Chain.createAuthenticated(relatedChains
              .cast<Web3ChainNetworkData<WalletSubstrateNetwork>>()));
          break;
        case NetworkType.aptos:
          auths.add(web3Chain.createAuthenticated(
              relatedChains.cast<Web3ChainNetworkData<WalletAptosNetwork>>()));
          break;
        case NetworkType.sui:
          auths.add(web3Chain.createAuthenticated(
              relatedChains.cast<Web3ChainNetworkData<WalletSuiNetwork>>()));
          break;
        case NetworkType.cosmos:
          auths.add(web3Chain.createAuthenticated(
              relatedChains.cast<Web3ChainNetworkData<WalletCosmosNetwork>>()));
        case NetworkType.bitcoinAndForked:
        case NetworkType.bitcoinCash:
          auths.add(web3Chain.createAuthenticated(relatedChains
              .cast<Web3ChainNetworkData<WalletBitcoinNetwork>>()));
        default:
      }
    }
    if (web3Networks.remove(NetworkType.bitcoinCash)) {
      web3Networks = [...web3Networks, NetworkType.bitcoinAndForked];
    }
    return Web3APPData(
        token: token,
        active: active,
        chains: auths,
        networks: web3Networks.toSet().toList(),
        applicationId: applicationId);
  }

  static String? toApplicationId(String? url) {
    final Uri? uri = Uri.tryParse(url ?? "");
    if (uri?.host.isEmpty ?? true) {
      return null;
    }
    final appId = Uri(host: uri!.host, scheme: uri.scheme, port: uri.port);
    return appId.normalizePath().toString();
  }

  Web3APPAuthentication._({
    required String name,
    required this.applicationId,
    required this.icon,
    required this.applicationKey,
    required List<Web3AccountAcitvity> activities,
    required List<int> token,
    bool active = true,
    Map<NetworkType, Web3Chain> chains = const {},
  })  : _chains = chains.imutable,
        token = token.asImmutableBytes,
        _activities = activities.immutable,
        _name = name,
        _active = active;

  void updateApplicationName(String name) {
    _name = name;
  }

  void toggleActive() {
    _active = !_active;
  }

  Web3APPAuthentication clone() {
    return Web3APPAuthentication._(
        name: name,
        applicationId: applicationId,
        icon: icon,
        applicationKey: applicationKey,
        token: token,
        chains: {for (final i in _chains.entries) i.key: i.value.clone()},
        active: active,
        activities: _activities);
  }

  factory Web3APPAuthentication.create(
      {required String applicationId,
      required String applicationKey,
      required String name,
      required APPImage? icon,
      required List<int> token}) {
    if (toApplicationId(applicationId) != applicationId) {
      throw Web3RequestExceptionConst.invalidHost;
    }
    return Web3APPAuthentication._(
        name: name,
        applicationId: applicationId,
        icon: icon,
        active: true,
        token: token,
        applicationKey: applicationKey,
        chains: {},
        activities: []);
  }
  factory Web3APPAuthentication.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.web3App);

    return Web3APPAuthentication._(
        applicationId: values.elementAt(0),
        name: values.elementAt(1),
        icon: values.getCborTag(2)?.to<APPImage, CborObject>(
            (e) => APPImage.fromCborBytesOrObject(obj: e)),
        chains: values.elementAt<CborMapValue>(3).generateMap(
            (e) => NetworkType.fromName(e.value),
            (p0) => Web3Chain.deserialize(object: p0)),
        active: values.elementAt(4),
        token: values.elementAt(5),
        applicationKey: values.elementAt(6),
        activities: values
            .elementAsListOf<CborTagValue>(7, emyptyOnNull: true)
            .map((e) => Web3AccountAcitvity.deserialize(object: e))
            .toList());
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          applicationId,
          name,
          icon?.toCbor(),
          CborMapValue.fixedLength(
              {for (final i in _chains.entries) i.key.name: i.value.toCbor()}),
          active,
          CborBytesValue(token),
          applicationKey,
          CborListValue.fixedLength(_activities.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.web3App);
  }

  void disconnectChain(NetworkType network) {
    final updateChain = _chains[network]?.disconnect();
    if (updateChain == null) return;
    final chains = Map<NetworkType, Web3Chain>.from(_chains);
    chains[network] = updateChain;
    _chains = chains.imutable;
  }

  T? getChainFromNetworkType<T extends Web3ChainNetwork>(NetworkType network,
      {bool allowDisable = false}) {
    if (!allowDisable) {
      if (!active) return null;
    }

    Web3Chain? chain = _chains[network];
    if (network.isBitcoin) {
      chain = _chains[NetworkType.bitcoinAndForked];
    }
    switch (network) {
      case NetworkType.ethereum:
        chain ??= Web3EthereumChain.create();
        break;
      case NetworkType.tron:
        chain ??= Web3TronChain.create();
        break;
      case NetworkType.solana:
        chain ??= Web3SolanaChain.create();
        break;
      case NetworkType.ton:
        chain ??= Web3TonChain.create();
        break;
      case NetworkType.stellar:
        chain ??= Web3StellarChain.create();
        break;
      case NetworkType.substrate:
        chain ??= Web3SubstrateChain.create();
        break;
      case NetworkType.aptos:
        chain ??= Web3AptosChain.create();
        break;
      case NetworkType.sui:
        chain ??= Web3SuiChain.create();
        break;
      case NetworkType.cosmos:
        chain ??= Web3CosmosChain.create();
        break;
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        chain ??= Web3BitcoinChain.create();
        break;
      default:
        throw Web3RequestExceptionConst.networkDoesNotExists;
    }
    if (chain is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return chain;
  }

  T? getChain<T extends Web3ChainNetwork>(NetworkType network) {
    Web3Chain? chain = _chains[network];
    if (network.isBitcoin) {
      chain = _chains[NetworkType.bitcoinAndForked];
    }
    if (chain is! T?) {
      throw WalletException.invalidArgruments(
          ["$T", chain.runtimeType.toString()]);
    }
    return chain;
  }

  void updateChainAccount(Web3Chain webChain) {
    final chains = Map<NetworkType, Web3Chain>.from(_chains);
    chains[webChain.network] = webChain;
    _chains = chains.imutable;
  }

  void addActivity({required Web3Request request, String? url}) {
    String? path;
    String? address;
    int? chainId;
    if (url != null) {
      path = Uri.tryParse(url)?.path.trim() ?? '';
      if (path.isEmpty || path == '/' || path == applicationId) {
        path = null;
      }
    }
    if (request is Web3NetworkRequest) {
      chainId = request.chain.network.value;
      address = request.params.account?.addressStr;
    }
    final newAcctivity = Web3AccountAcitvity(
        method: request.params.method.name,
        path: path,
        address: address,
        id: chainId);
    final activities = [newAcctivity, ..._activities]
      ..sort((a, b) => b.date.compareTo(a.date));
    _activities = activities.imutable;
  }

  void clearActivities() {
    _activities = <Web3AccountAcitvity>[].immutable;
  }
}

class Web3APPData with CborSerializable {
  final bool active;
  final String applicationId;
  final List<int> token;
  final List<NetworkType> networks;
  List<Web3ChainAuthenticated> _chains;
  List<Web3ChainAuthenticated> get chains => _chains;

  T? getAuth<T extends Web3ChainAuthenticated>(NetworkType networkType) {
    if (networkType.isBitcoin) {
      return _chains.firstWhereOrNull((e) => e.networkType.isBitcoin)?.cast();
    }
    return _chains
        .firstWhereOrNull((e) => e.networkType == networkType)
        ?.cast();
  }

  Web3APPData._({
    required List<int> token,
    required List<NetworkType> networks,
    required this.applicationId,
    this.active = true,
    List<Web3ChainAuthenticated> chains = const [],
  })  : _chains = chains.imutable,
        token = token.asImmutableBytes,
        networks = networks.immutable;

  factory Web3APPData(
      {required List<int> token,
      required List<NetworkType> networks,
      required String applicationId,
      List<Web3ChainAuthenticated> chains = const [],
      bool active = true}) {
    return Web3APPData._(
        active: active,
        token: token,
        chains: chains,
        networks: networks,
        applicationId: applicationId);
  }
  factory Web3APPData.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.web3App);
    return Web3APPData._(
        chains: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3ChainAuthenticated.deserialize(object: e))
            .toList(),
        active: values.elementAt(1),
        token: values.elementAt(2),
        networks: values
            .elementAsListOf<CborBytesValue>(3)
            .map((e) => NetworkType.fromTag(e.value))
            .toList(),
        applicationId: values.elementAs(4));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(_chains.map((e) => e.toCbor()).toList()),
          active,
          CborBytesValue(token),
          CborListValue.fixedLength(
              networks.map((e) => CborBytesValue(e.tag)).toList()),
          applicationId
        ]),
        CborTagsConst.web3App);
  }
}
