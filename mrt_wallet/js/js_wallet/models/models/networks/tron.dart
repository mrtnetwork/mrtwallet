import 'dart:js_interop';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/numbers/numbers.dart';
import 'ethereum.dart';

class JSTronConst {
  static const String defaultTronWebEndpoint = 'https://api.shasta.trongrid.io';
}

@JS("tron")
external set tron(Proxy<TIP1193>? tron);
@JS("tronWeb")
external set tronWeb_(Proxy<TronWeb>? tronWeb);
@JS("tronLink")
external set tronLink(Proxy<TIP1193>? tronLink);

class JSTronDefaultAddress {
  final String base58;
  final String hex;
  const JSTronDefaultAddress({required this.base58, required this.hex});
  factory JSTronDefaultAddress.fromJson(Map<String, dynamic> json) {
    return JSTronDefaultAddress(base58: json["base58"], hex: json["hex"]);
  }

  Map<String, dynamic> toJson() {
    return {"base58": base58, "hex": hex};
  }

  @override
  String toString() {
    return base58;
  }

  @override
  bool operator ==(other) {
    if (other is! JSTronDefaultAddress) return false;
    return hex == other.hex;
  }

  @override
  int get hashCode => hex.hashCode ^ base58.hashCode;
}

@JS()
extension type TronLinkParams(JSAny _) implements JSAny {
  external set dappIcon(String _);
  external set dappName(String _);
  external set openUrlWhenWalletNotFound(bool _);
  external set openTronLinkAppOnMobile(bool _);
}
extension type TronWebOptions._(JSAny _) implements JSAny {
  external factory TronWebOptions(
      {String? fullNode, String? solidityNode, String? privateKey});
}

@JS("TronWeb")
extension type TronWeb._(JSAny _) implements JSAny {
  external factory TronWeb(
      String? solidityNode, String? eventServer, String? privateKey);
  static TronWeb defaultTronWeb() {
    final tronWeb = TronWeb(JSTronConst.defaultTronWebEndpoint,
        JSTronConst.defaultTronWebEndpoint, JSTronConst.defaultTronWebEndpoint);
    return tronWeb;
  }

  external bool isAddress(JSAny _);
  @JS("trx")
  external TronWebTRX get trx;
  @JS("trx")
  external set trx_(Proxy<TronWebTRX> trx);

  external set setSolidityNode(JSFunction setAddress);
  external set setFullNode(JSFunction setPrivateKey);
  external set setAddress(JSFunction setAddress);
  external set setPrivateKey(JSFunction setPrivateKey);
  external set defaultPrivateKey(String s);
  external set solidityNode(HttpProvider? solidityNode);
  external set fullNode(HttpProvider? fullNode);
  external void setEventServer(HttpProvider? fullNode);
  external set setHeader(JSFunction setHeader);
  external set setFullNodeHeader(JSAny? setFullNodeHeader);
  external set setDefaultBlock(JSAny? fullNodsetDefaultBlocke);

  external HttpProvider get solidityNode;
  external HttpProvider get fullNode;
  external Proxy<JSTronAddress> get defaultAddress;
  external set defaultAddress(Proxy<JSTronAddress> defaultAddress);
}

@JS("TronWeb.providers.HttpProvider")
extension type HttpProvider._(JSAny _) implements JSAny {
  external factory HttpProvider(String host);
  external String get host;
  external String get statusPage;
  external set statusPage(String _);
}

@JS("TronWeb.types.DefaultAddress")
extension type JSTronAddress._(JSAny _) implements JSAny {
  external factory JSTronAddress({required JSAny base58, required JSAny hex});
  @JS("base58")
  external set base58(JSAny _);
  external JSAny get base58;
  external JSAny get hex;
  @JS("hex")
  external set hex(JSAny _);

  void setAddress(JSTronDefaultAddress? address) {
    base58 = address?.base58.toJS ?? false.toJS;
    hex = address?.hex.toJS ?? false.toJS;
  }
}

@JS("TIP-1193")
extension type TIP1193(JSObject _) implements EIP1193 {
  @JS("tronWeb")
  external set tronWeb(Proxy tronWeb);
  @JS("ready")
  external set ready(bool ready);
  external set config(TronLinkParams _);

  static TIP1193 setup(
      {required JSFunction request,
      required JSFunction on,
      required JSFunction removeListener,
      required JSFunction disconnect,
      required JSFunction cancelAllListener,
      required Proxy tronWeb,
      required JSFunction enable,
      required JSFunction sendWalletRequest,
      required TronLinkParams params}) {
    final tip = TIP1193(JSObject());
    tip.sendWalletRequest = sendWalletRequest;
    tip.cancelAllListener = cancelAllListener;
    tip.cancelAllListener = removeListener;
    tip.config = params;
    tip.request = request;
    tip.on = on;
    tip.removeListener = removeListener;
    tip.tronWeb = tronWeb;
    tip.providerInfo = EIP6963ProviderInfo.providerInfo;
    tip.ready = true;
    tip.enable = enable;
    final eth = MRTJsObject.freeze(tip);
    return eth;
  }
}

@JS()
extension type TronWebTRX(JSObject _) implements MRTJsObject {
  @JS("sign")
  external set signTransaction__(JSFunction f);

  @JS("multiSign")
  external set multiSignTransaction(JSFunction f);

  @JS("signMessageV2")
  external set signMessageV2__(JSFunction f);
}

class TronWebNodeInfo {
  final String solidityNode;
  final String fullNode;
  final String chainId;
  final String? base58;
  final String? hex;
  final String? eventServer;
  const TronWebNodeInfo(
      {required this.solidityNode,
      required this.fullNode,
      required this.chainId,
      this.base58,
      this.hex,
      this.eventServer});
  factory TronWebNodeInfo.fromJson(Map<String, dynamic> json) {
    return TronWebNodeInfo(
        solidityNode: json["solidityNode"],
        fullNode: json["fullNode"],
        chainId: json["chainId"],
        hex: json["hex"],
        base58: json["base58"],
        eventServer: json["eventServer"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "solidityNode": solidityNode,
      "fullNode": fullNode,
      "chainId": chainId,
      "hex": hex,
      "eventServer": eventServer,
      "base58": base58
    };
  }

  TronWeb toTronWeb() {
    final tronWeb = TronWeb(fullNode, fullNode, eventServer);
    return tronWeb;
  }
}

class TronAccountsChanged {
  final List<String> accounts;
  final JSTronDefaultAddress? defaultAddress;
  TronAccountsChanged(
      {required List<String> accounts, required this.defaultAddress})
      : accounts = accounts.imutable;
  factory TronAccountsChanged.fromJson(Map<String, dynamic> json) {
    return TronAccountsChanged(
        accounts: (json["accounts"] as List).cast(),
        defaultAddress: json["defaultAddress"] == null
            ? null
            : JSTronDefaultAddress.fromJson(json["defaultAddress"]));
  }
  Map<String, dynamic> toJson() {
    return {"accounts": accounts, "defaultAddress": defaultAddress?.toJson()};
  }

  JSAny? get toJSEvent => accounts.jsify();

  @JSExport("toString")
  @override
  String toString() {
    return "TronAccountsChanged${toJson()}";
  }
}

class TronChainChanged {
  @JSExport("chainId")
  final String chainId;
  final BigInt netVersion;
  final String solidityNode;
  final String fullNode;
  final JSTronDefaultAddress? address;
  TronChainChanged(
      {required this.netVersion,
      required this.fullNode,
      required this.solidityNode,
      required this.address})
      : chainId = netVersion.toRadix16;
  factory TronChainChanged.fromJson(Map<String, dynamic> json) {
    return TronChainChanged(
        netVersion: BigInt.parse(json["net_version"]),
        fullNode: json["fullNode"],
        solidityNode: json["solidityNode"],
        address: json["address"] == null
            ? null
            : JSTronDefaultAddress.fromJson((json["address"] as Map).cast()));
  }
  Map<String, dynamic> toJson() {
    return {
      "net_version": netVersion.toString(),
      "fullNode": fullNode,
      "solidityNode": solidityNode,
      "address": address?.toJson()
    };
  }

  JSAny? get toJSEvent => createJSInteropWrapper(this);
  @JSExport("toString")
  @override
  String toString() {
    return "ProviderConnectInfo${{"chainId": chainId}}";
  }
}
