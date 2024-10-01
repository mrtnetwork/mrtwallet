import 'dart:js_interop';
import 'package:mrt_wallet/app/core.dart';
import '../../models.dart';

@JS("stellar")
external set stellar(Proxy? stellar);
extension type StellarWalletAdapter(JSObject _) implements MRTNetworkAdapter {
  external set publicKey(JSObject? publicKey);

  external bool get isConnected;
  external set isConnected(bool isConnected);
  external set connect(JSFunction f);

  external set signMessage(JSFunction f);
  @JS("signTransaction")
  external set signTransaction(JSFunction f);
  @JS("signAndSendTransaction")
  external set signAndSendTransaction(JSFunction f);
  @JS("signAllTransactions")
  external set signAllTransactions(JSFunction f);
  @JS("signAndSendAllTransactions")
  external set signAndSendAllTransactions(JSFunction f);

  external set on(JSFunction f);
  external set removeListener(JSFunction f);

  factory StellarWalletAdapter.setup() {
    return StellarWalletAdapter(JSObject());
  }
}

class StellarAccountsChanged {
  final List<String> accounts;
  final String? defaultAddress;
  final StellarProviderConnectInfo connectInfo;
  StellarAccountsChanged({
    required List<String> accounts,
    required this.defaultAddress,
    required this.connectInfo,
  }) : accounts = accounts.imutable;
  factory StellarAccountsChanged.fromJson(Map<String, dynamic> json) {
    return StellarAccountsChanged(
        accounts: (json["accounts"] as List).cast(),
        defaultAddress: json["defaultAddress"],
        connectInfo: StellarProviderConnectInfo.fromJson(json["connectInfo"]));
  }
  Map<String, dynamic> toJson() {
    return {
      "accounts": accounts,
      "defaultAddress": defaultAddress,
      "connectInfo": connectInfo.toJson()
    };
  }

  JSAny? get accountJS => accounts.map((e) => e.toJS).toList().toJS;

  @JSExport("toString")
  @override
  String toString() {
    return "StellarAccountsChanged${toJson()}";
  }
}

class StellarProviderConnectInfo {
  @JSExport("passphrase")
  final String passphrase;

  StellarProviderConnectInfo(this.passphrase);
  factory StellarProviderConnectInfo.fromJson(Map<String, dynamic> json) {
    return StellarProviderConnectInfo(json["passphrase"]);
  }
  Map<String, dynamic> toJson() {
    return {"passphrase": passphrase};
  }

  JSAny? get toJS => createJSInteropWrapper(this);
  @JSExport("toString")
  @override
  String toString() {
    return passphrase;
  }
}
