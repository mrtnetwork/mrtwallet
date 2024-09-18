import 'dart:js_interop';
import 'package:mrt_wallet/app/core.dart';
import '../../models.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

extension type TonFeature._(JSObject _) implements MRTJsObject {
  external factory TonFeature({String name});
}
extension type TonBridgeInjected._(JSObject _) implements TonBridge {
  external factory TonBridgeInjected(
      {required String name, required String key});
  static TonBridgeInjected instance = TonBridgeInjected(name: "js", key: "MRT");
}

extension type TonBridge._(JSObject _) implements MRTJsObject {
  external factory TonBridge({String name});
}

extension type SendTransactionFeature._(JSObject _) implements TonFeature {
  external factory SendTransactionFeature(
      {required String name, required int maxMessages});
  static SendTransactionFeature instance =
      SendTransactionFeature(name: "SendTransaction", maxMessages: 4);
}
extension type SignDataFeature._(JSObject _) implements TonFeature {
  external factory SignDataFeature({required String name});
  static SignDataFeature instance = SignDataFeature(name: "SignData");
}
extension type TonDeviceInfo._(JSObject _) implements MRTJsObject {
  external factory TonDeviceInfo(
      {required String platform,
      required String appName,
      required String appVersion,
      required int maxProtocolVersion,
      required JSArray<TonFeature> features});
  static TonDeviceInfo instance = TonDeviceInfo(
      appName: "MRT",
      appVersion: "1.0.0",
      features:
          [SendTransactionFeature.instance, SignDataFeature.instance].toJS,
      maxProtocolVersion: 2,
      platform: "browser");
}

extension type WalletInfoDTO._(JSObject _) implements MRTJsObject {
  external String get name;
  @JS("app_name")
  external String get app_name;
  external String get tondns;
  external String get image;
  @JS("about_url")
  external String get aboutUrl;
  @JS("universal_url")
  external String get universalUrl;
  external String? get deepLink;
  external JSArray<JSString> get platforms;

  external factory WalletInfoDTO({
    required String name,
    required String app_name,
    String? tondns,
    required String? image,
    required String about_url,
    String? universalUrl,
    required JSArray<JSString> platforms,
    required JSArray<TonBridge> bridge,
  });
  static WalletInfoDTO instance = WalletInfoDTO(
    about_url: "https://github.com/mrtnetwork/mrtwallet",
    app_name: "MRT",
    image: null, //"https://github.com/mrtnetwork/mrtwallet",
    name: "MRT wallet",
    bridge: [TonBridgeInjected.instance].toJS,
    platforms: <String>[
      "android",
      "chrome",
      "firefox",
      "windows",
      "macos",
    ].map((e) => e.toJS).toList().toJS,
  );
}

enum TonChainId {
  mainnet(value: '-239', workchain: 0),
  testnet(value: '-3', workchain: -1);

  final String value;
  final int workchain;

  const TonChainId({required this.value, required this.workchain});
  static TonChainId fromNetworkId(int id) {
    return values.firstWhere((e) => e.workchain == id,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
  }
}

extension type TonAddressItemDTO._(JSObject _) implements MRTJsObject {
  external String get name;
  external String get address;
  external String get network;
  external String get walletStateInit;
  external String get publicKey;

  external factory TonAddressItemDTO({
    required String name,
    required String address,
    required String network,
    required String walletStateInit,
    required String publicKey,
  });

  factory TonAddressItemDTO.create({
    required String address,
    required String network,
    required String walletStateInit,
    required String publicKey,
  }) {
    return TonAddressItemDTO(
        name: "ton_addr",
        address: address,
        network: network,
        walletStateInit: walletStateInit,
        publicKey: publicKey);
  }
  factory TonAddressItemDTO.fromJson(Map<String, dynamic> json) {
    return TonAddressItemDTO(
        name: "ton_addr",
        address: json["address"],
        network: json["network"],
        walletStateInit: json["walletStateInit"],
        publicKey: json["publicKey"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "network": network,
      "walletStateInit": walletStateInit,
      "publicKey": publicKey
    };
  }
}

enum ConnectEventErrorCodes {
  unknownError(0),
  badRequestError(1),
  manifestNotFoundError(2),
  manifestContentError(3),
  unknownAppError(100),
  userRejectsError(300),
  methodNotSupported(400);

  final int code;

  const ConnectEventErrorCodes(this.code);
}

@JS()
extension type TonWalletAdapter(JSObject _) implements MRTNetworkAdapter {
  // external factory TonWalletAdapter();
  // external factory TonWalletAdapter(
  //     {required TonDeviceInfo deviceInfo,
  //     required int protocolVersion,
  //     required bool isWalletBrowser,
  //     required WalletInfoDTO walletInfo});
  // external TonDeviceInfo get deviceInfo;
  // external int get protocolVersion;
  // external bool get isWalletBrowser;
  // external WalletInfoDTO get walletInfo;
  // external set listen(JSFunction f);
  // external set connect(JSFunction f);
  // external set restoreConnection(JSFunction f);
  // external set send(JSFunction f);
  // external set sendTransaction(JSFunction f);
}

extension type TonJSTranasctionMessage._(JSObject _) implements MRTJsObject {
  external factory TonJSTranasctionMessage(
      {required String address,
      required String amount,
      String? stateInit,
      String? payload});
  external String get address;
  external String get amount;
  external String? stateInit;
  external String? payload;
  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "amount": amount,
      "stateInit": stateInit,
      "payload": payload
    };
  }
}
extension type TonJSTranasction._(JSObject _) implements MRTJsObject {
  external factory TonJSTranasction(
      {required int validUntil,
      String? network,
      String? from,
      required JSArray<TonJSTranasctionMessage> messages});
  external int get validUntil;
  external String? network;
  external String? from;
  external JSArray<TonJSTranasctionMessage> messages;

  Map<String, dynamic> toJson() {
    return {
      "validUntil": validUntil,
      "network": network,
      "from": from,
      "messages": messages.toDart.map((e) => e.toJson()).toList()
    };
  }
}

class TonAccountsChanged {
  final List<String> accounts;
  final String? defaultAddress;
  TonAccountsChanged({required List<String> accounts, this.defaultAddress})
      : accounts = accounts.imutable;
  factory TonAccountsChanged.fromJson(Map<String, dynamic> json) {
    return TonAccountsChanged(
        accounts: (json["accounts"] as List).cast(),
        defaultAddress: json["defaultAddress"]);
  }
  Map<String, dynamic> toJson() {
    return {"accounts": accounts, "defaultAddress": defaultAddress};
  }

  JSAny? get accountJS => accounts.jsify();

  @JSExport("toString")
  @override
  String toString() {
    return "TonAccountsChanged${toJson()}";
  }
}

class TonChainChanged {
  @JSExport("workChain")
  final int workChain;

  TonChainChanged(this.workChain);
  factory TonChainChanged.fromJson(Map<String, dynamic> json) {
    return TonChainChanged(json["workChain"]);
  }
  Map<String, dynamic> toJson() {
    return {"workChain": workChain};
  }

  JSAny? get toJS => createJSInteropWrapper(this);

  @JSExport("toString")
  @override
  String toString() {
    return "TonChainChanged${toJson()}";
  }
}

@JS("TonRequestParams")
extension type TonRequestParams._(JSObject o) implements Web3JSRequestParams {
  external factory TonRequestParams({String? method, JSAny? params});
  external String get method;
  external set method(String? method);
  external JSAny? get params;
}
