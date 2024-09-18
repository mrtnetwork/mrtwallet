import 'dart:js_interop';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/numbers/numbers.dart';
import 'ethereum.dart';

@JS("tron")
external set tron(Proxy? tron);

class JSTronAddress {
  @JSExport("base58")
  final String base58;
  @JSExport("hex")
  final String hex;
  const JSTronAddress({required this.base58, required this.hex});
  factory JSTronAddress.fromJson(Map<String, dynamic> json) {
    return JSTronAddress(base58: json["base58"], hex: json["hex"]);
  }

  Map<String, dynamic> toJson() {
    return {"base58": base58, "hex": hex};
  }

  @JSExport("toString")
  @override
  String toString() {
    return base58;
  }

  @override
  operator ==(other) {
    if (other is! JSTronAddress) return false;
    return hex == other.hex;
  }

  JSObject get toJS => createJSInteropWrapper(this);

  @override
  int get hashCode => hex.hashCode ^ base58.hashCode;
}

@JS()
extension type TronWebConstroctorOption._(JSAny _) implements JSAny {
  external factory TronWebConstroctorOption(String? fullHost,
      String? solidityNode, String? eventServer, String? privateKey);
}
@JS("TronWeb")
extension type TronWeb._(JSAny _) implements JSAny {
  external factory TronWeb(
      String? solidityNode, String? eventServer, String? privateKey);

  @JS("trx")
  external TronWebTRX get trx;
  @JS("trx")
  external set trx_(Proxy trx);

  external set setSolidityNode(JSFunction setAddress);
  external set setFullNode(JSFunction setPrivateKey);
  external set setAddress(JSFunction setAddress);
  external set setPrivateKey(JSFunction setPrivateKey);
  external set solidityNode(HttpProvider? solidityNode);
  external set fullNode(HttpProvider? fullNode);
  external set setHeader(JSFunction setHeader);
  external set setFullNodeHeader(JSAny? setFullNodeHeader);
  external set setDefaultBlock(JSAny? fullNodsetDefaultBlocke);
  external HttpProvider get solidityNode;
  external HttpProvider get fullNode;

  external JSObject? get defaultAddress;
  external set defaultAddress(JSObject? defaultAddress);
}
@JS("TronWeb.providers.HttpProvider")
extension type HttpProvider._(JSAny _) implements JSAny {
  external factory HttpProvider(String host);
  external String get host;
}

@JS("TIP-1193")
extension type TIP1193(JSObject _) implements EIP1193 {
  @JS("tronWeb")
  external set tronWeb(Proxy tronWeb);

  external set ready(bool ready);

  static TIP1193 setup({
    required JSFunction request,
    required JSFunction on,
    required JSFunction removeListener,
    required JSFunction disconnect,
    required JSFunction cancelAllListener,
    required Proxy tronWeb,
    required JSFunction enable,
    required JSFunction sendWalletRequest,
  }) {
    final tip = TIP1193(JSObject());
    tip.sendWalletRequest = sendWalletRequest;
    tip.cancelAllListener = cancelAllListener;
    tip.cancelAllListener = removeListener;

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

  JSTronAddress? toAddress() {
    if (base58 == null || hex == null) return null;
    return JSTronAddress(base58: base58!, hex: hex!);
  }

  TronWeb toTronWeb() {
    try {
      final tronWeb = TronWeb(fullNode, fullNode, eventServer);
      final addr = toAddress();
      tronWeb.defaultAddress =
          addr == null ? null : createJSInteropWrapper(addr);
      return tronWeb;
    } catch (e) {
      rethrow;
    }
  }
}

class TronAccountsChanged {
  final List<String> accounts;
  final JSTronAddress? defaultAddress;
  TronAccountsChanged(
      {required List<String> accounts, required this.defaultAddress})
      : accounts = accounts.imutable;
  factory TronAccountsChanged.fromJson(Map<String, dynamic> json) {
    return TronAccountsChanged(
        accounts: (json["accounts"] as List).cast(),
        defaultAddress: json["defaultAddress"] == null
            ? null
            : JSTronAddress.fromJson(json["defaultAddress"]));
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
  TronChainChanged(
      {required this.netVersion,
      required this.fullNode,
      required this.solidityNode})
      : chainId = netVersion.toRadix16;
  factory TronChainChanged.fromJson(Map<String, dynamic> json) {
    return TronChainChanged(
        netVersion: BigInt.parse(json["net_version"]),
        fullNode: json["fullNode"],
        solidityNode: json["solidityNode"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "net_version": netVersion.toString(),
      "fullNode": fullNode,
      "solidityNode": solidityNode
    };
  }

  JSAny? get toJSEvent => createJSInteropWrapper(this);
  @JSExport("toString")
  @override
  String toString() {
    return "ProviderConnectInfo${{"chainId": chainId}}";
  }
}
