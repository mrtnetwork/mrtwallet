import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/models/models/image.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/map/extension.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/request/params.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

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

  T? getChain<
          NETWORKADDRESS,
          T extends Web3Chain<NETWORKADDRESS, APPCHAINNETWORK<NETWORKADDRESS>,
              Web3ChainAccount<NETWORKADDRESS>>>(
      {NETWORKADDRESS? address,
      required APPCHAINNETWORK<NETWORKADDRESS> chain}) {
    if (!active) {
      throw Web3RequestExceptionConst.bannedHost;
    }
    final chainPermission = _chains[chain.network.type] as T?;
    if (address != null) {
      final accountPermission =
          chainPermission?.getAccountPermission(address: address, chain: chain);
      if (accountPermission == null) {
        throw Web3RequestExceptionConst.missingPermission;
      }
    }
    return chainPermission;
  }

  T? getChainFromNetworkType<T extends Web3ChainNetwork>(NetworkType network) {
    if (!active) return null;
    return _chains[network] as T?;
  }

  void updateChainAccount(Web3Chain webChain) {
    final chains = Map<NetworkType, Web3Chain>.from(_chains);
    chains[webChain.network] = webChain;
    _chains = chains.imutable;
  }

  void disconnect(NetworkType network) {
    final updateChain = _chains[network];
    if (updateChain != null) {
      _chains[network] = updateChain.disconnect();
    }
  }

  void addActivity({required Web3RequestParams param, String? url}) {
    final chain = _chains[param.method.network];
    if (chain == null) {
      throw Web3RequestExceptionConst.internalError;
    }
    chain.addActivity(param: param, url: url);
  }
}
