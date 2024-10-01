import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/models/models/image.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/map/extension.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/request/params.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/permission/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
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
  static String? toApplicationId(String? url) {
    Uri? uri = Uri.tryParse(url ?? "");
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
        token = BytesUtils.toBytes(token);
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
