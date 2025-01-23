import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/request/params.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/permission/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/permission/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/models/permission.dart';

class Web3APPAuthentication with CborSerializable {
  final String applicationId;
  final String applicationKey;
  final String name;
  final APPImage? icon;
  final bool active;
  final List<int> token;
  Map<NetworkType, Web3Chain> _chains;

  Web3APPData createAuth(List<Web3ChainNetworkData> networks,
      {List<NetworkType>? web3Networks}) {
    List<Web3ChainAuthenticated> auths = [];
    web3Networks ??= Web3Const.supportedWeb3;
    for (final i in web3Networks) {
      final web3Chain = getChainFromNetworkType(i);
      if (web3Chain == null) continue;
      final relatedChains = networks.where((e) => e.network.type == i).toList();
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
        default:
      }
    }
    return Web3APPData(token: token, active: active, chains: auths);
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
    required this.name,
    required this.applicationId,
    required this.icon,
    required this.applicationKey,
    required List<int> token,
    this.active = true,
    Map<NetworkType, Web3Chain> chains = const {},
  })  : _chains = chains.imutable,
        token = token.asImmutableBytes;
  Web3APPAuthentication clone({String? name, bool? active}) {
    return Web3APPAuthentication(
        name: name ?? this.name,
        applicationId: applicationId,
        icon: icon,
        applicationKey: applicationKey,
        token: token,
        chains: {for (final i in _chains.entries) i.key: i.value.clone()},
        active: active ?? this.active);
  }

  factory Web3APPAuthentication(
      {required String applicationId,
      required String applicationKey,
      required String name,
      required APPImage? icon,
      required List<int> token,
      Map<NetworkType, Web3Chain> chains = const {},
      bool active = true}) {
    if (toApplicationId(applicationId) != applicationId) {
      throw Web3RequestExceptionConst.invalidHost;
    }
    return Web3APPAuthentication._(
        name: name,
        applicationId: applicationId,
        icon: icon,
        active: active,
        token: token,
        applicationKey: applicationKey,
        chains: chains);
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
        applicationKey: values.elementAt(6));
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
          applicationKey
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

  T? getChainFromNetworkType<T extends Web3ChainNetwork>(NetworkType network) {
    if (!active) return null;
    Web3Chain? chain = _chains[network];
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
      default:
        throw Web3RequestExceptionConst.networkNotSupported;
    }
    if (chain is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return chain;
  }

  void updateChainAccount(Web3Chain webChain) {
    final chains = Map<NetworkType, Web3Chain>.from(_chains);
    chains[webChain.network] = webChain;
    _chains = chains.imutable;
  }

  void addActivity({required Web3RequestParams param, String? url}) {
    final chain = _chains[param.method.network];
    if (chain == null) {
      throw Web3RequestExceptionConst.internalError;
    }
    chain.addActivity(param: param, url: url);
  }
}

class Web3APPData with CborSerializable {
  final bool active;
  final List<int> token;
  List<Web3ChainAuthenticated> _chains;
  List<Web3ChainAuthenticated> get chains => _chains;

  T? getAuth<T extends Web3ChainAuthenticated>(NetworkType networkType) {
    return _chains
        .firstWhereNullable((e) => e.networkType == networkType)
        ?.cast();
  }

  Web3APPData._({
    required List<int> token,
    this.active = true,
    List<Web3ChainAuthenticated> chains = const [],
  })  : _chains = chains.imutable,
        token = token.asImmutableBytes;

  factory Web3APPData(
      {required List<int> token,
      List<Web3ChainAuthenticated> chains = const [],
      bool active = true}) {
    return Web3APPData._(active: active, token: token, chains: chains);
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
    );
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(_chains.map((e) => e.toCbor()).toList()),
          active,
          CborBytesValue(token),
        ]),
        CborTagsConst.web3App);
  }
}
