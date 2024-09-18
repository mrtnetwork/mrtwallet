import 'dart:js_interop';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import '../../models.dart';

@JS("BN")
extension type JSBN._(JSAny _) implements JSAny {
  external factory JSBN(JSAny val);
  external bool eq(JSAny? other);
}

@JS("solanaWeb3")
external JSAny? get solanaWeb3;
@JS("solana")
external set solana(Proxy? solana);
extension type SolanaWalletAdapter(JSObject _) implements MRTNetworkAdapter {
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

  factory SolanaWalletAdapter.setup() {
    return SolanaWalletAdapter(JSObject());
  }
}
@JS("Uint8Array")
extension type JSUint8Array(JSAny _) implements JSAny {
  external static JSUint8Array from(JSAny? v);
  external JSUint8Array slice();
  factory JSUint8Array.fromList(List<int> bytes) {
    return JSUint8Array.from(bytes.jsify());
  }
  List<int> toListInt() {
    return (dartify() as List?)?.cast() ?? [];
  }
}
@JS()
extension type JSSolanaTransactionSerializationConfig._(JSObject _)
    implements JSAny {
  external factory JSSolanaTransactionSerializationConfig(
      {required bool verifySignatures});
}
@JS()
extension type JSSolanaSignMessageResponse._(JSObject _) implements JSAny {
  external factory JSSolanaSignMessageResponse(
      {required JSUint8Array signature, required JSObject publicKey});

  factory JSSolanaSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return JSSolanaSignMessageResponse(
        signature: JSUint8Array.fromList((json["signature"] as List).cast()),
        publicKey: JSSolanaPublicKey(
                base58: json["signer"],
                bytes: (json["signerAddressBytes"] as List).cast())
            .toJS);
  }
}

class JSSolanaSignTransactionResponse {
  final List<int> signature;
  final List<int> addressBytes;
  final String address;
  JSSolanaSignTransactionResponse(
      {required List<int> signature,
      required List<int> addressBytes,
      required this.address})
      : signature = BytesUtils.toBytes(signature, unmodifiable: true),
        addressBytes = BytesUtils.toBytes(addressBytes, unmodifiable: true);
  factory JSSolanaSignTransactionResponse.fromJson(Map<String, dynamic> json) {
    return JSSolanaSignTransactionResponse(
        signature: (json["signature"] as List).cast(),
        addressBytes: (json["signerAddressBytes"] as List).cast(),
        address: json["signer"]);
  }
}

@JS()
extension type JSSolanaTranasctionSendOptions._(JSObject _) implements JSAny {
  external factory JSSolanaTranasctionSendOptions(
      {bool? skipPreflight,
      String? preflightCommitment,
      int? minContextSlot,
      int? maxRetries});
  factory JSSolanaTranasctionSendOptions.defaulConfig() {
    return JSSolanaTranasctionSendOptions(skipPreflight: false);
  }
  external bool? get skipPreflight;
  external String? get preflightCommitment;
  external int? get minContextSlot;
  external JSArray<JSAny>? get signers;
  external int? get maxRetries;
  Map<String, dynamic> toJson() {
    return {
      "skipPreflight": skipPreflight,
      "preflightCommitment": preflightCommitment,
      "minContextSlot": minContextSlot,
      "signers": hasSigner,
      "maxRetries": maxRetries
    };
  }

  bool get hasSigner => signers?.toDart.isNotEmpty ?? false;
}
extension type JSSolanaTransaction(JSObject _) implements JSAny {
  external JSUint8Array serialize(
      JSSolanaTransactionSerializationConfig? config);
  external void addSignature(JSObject pubkey, JSAny? signature);

  JSUint8Array transactionSerialize() {
    return serialize(
        JSSolanaTransactionSerializationConfig(verifySignatures: false));
  }
}
extension type SolanaWeb3JSPubKey._(JSObject _) implements JSAny {
  @JS("_bn")
  external JSAny? get _bn;
  external bool equals(JSAny? other);
}

class JSSolanaPublicKey {
  final String base58;
  final JSUint8Array bytes;
  const JSSolanaPublicKey._(this._bn,
      {required this.base58, required this.bytes});
  factory JSSolanaPublicKey(
      {required String base58, required List<int> bytes}) {
    final jsBuffer = JSUint8Array.from(bytes.jsify());
    return JSSolanaPublicKey._(JSBN(jsBuffer.slice()),
        base58: base58, bytes: jsBuffer);
  }
  factory JSSolanaPublicKey.fromJson(Map<String, dynamic> json) {
    return JSSolanaPublicKey(
        base58: json["base58"], bytes: (json["bytes"] as List).cast());
  }
  Map<String, dynamic> toJson() {
    return {"base58": base58, "bytes": bytes};
  }

  @JSExport("equals")
  bool equals(SolanaWeb3JSPubKey? other) {
    return _bn.eq(other?._bn);
  }

  @JSExport("_bn")
  final JSBN _bn;

  @JSExport("toBase58")
  String toBase58() {
    return base58;
  }

  @JSExport("toJSON")
  String toJSON() {
    return base58;
  }

  @JSExport("toString")
  @override
  String toString() {
    return base58;
  }

  @JSExport("toBytes")
  JSUint8Array toBytes() {
    return bytes.slice();
  }

  JSObject get toJS => createJSInteropWrapper(this);
}

class SolanaAccountsChanged {
  final List<String> accounts;
  final String? defaultAddress;
  final List<int>? defaultAddressBytes;
  final SolanaProviderConnectInfo connectInfo;
  SolanaAccountsChanged({
    required List<String> accounts,
    required this.defaultAddress,
    required List<int>? defaultAddressBytes,
    required this.connectInfo,
  })  : accounts = accounts.imutable,
        defaultAddressBytes =
            BytesUtils.tryToBytes(defaultAddressBytes, unmodifiable: true);
  factory SolanaAccountsChanged.fromJson(Map<String, dynamic> json) {
    return SolanaAccountsChanged(
        accounts: (json["accounts"] as List).cast(),
        defaultAddress: json["defaultAddress"],
        defaultAddressBytes: (json["defaultAddressBytes"] as List?)?.cast(),
        connectInfo: SolanaProviderConnectInfo.fromJson(json["connectInfo"]));
  }
  Map<String, dynamic> toJson() {
    return {
      "accounts": accounts,
      "defaultAddress": defaultAddress,
      "defaultAddressBytes": defaultAddressBytes,
      "connectInfo": connectInfo.toJson()
    };
  }

  JSAny? get accountJS => accounts.map((e) => e.toJS).toList().toJS;

  JSSolanaPublicKey? toJSPublicKey() {
    if (defaultAddress != null && defaultAddressBytes != null) {
      return JSSolanaPublicKey(
          base58: defaultAddress!, bytes: defaultAddressBytes!);
    }
    return null;
  }

  @JSExport("toString")
  @override
  String toString() {
    return "SolanaAccountsChanged${toJson()}";
  }
}

class ClientSolanaTransactionMessage {
  final int id;
  final List<int> message;
  final Map<String, dynamic>? sendOption;
  ClientSolanaTransactionMessage(
      {required this.id, required List<int> message, required this.sendOption})
      : message = BytesUtils.toBytes(message, unmodifiable: true);
  factory ClientSolanaTransactionMessage.fromJson(Map<String, dynamic> json) {
    return ClientSolanaTransactionMessage(
        id: json["id"],
        message: (json["message"] as List).cast(),
        sendOption: (json["sendOption"] as Map?)?.cast());
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "message": message, "sendOption": sendOption};
  }
}

class SolanaProviderConnectInfo {
  @JSExport("genesisBlock")
  final String genesisBlock;

  SolanaProviderConnectInfo(this.genesisBlock);
  factory SolanaProviderConnectInfo.fromJson(Map<String, dynamic> json) {
    return SolanaProviderConnectInfo(json["genesisBlock"]);
  }
  Map<String, dynamic> toJson() {
    return {"genesisBlock": genesisBlock};
  }

  JSAny? get toJS => createJSInteropWrapper(this);
  @JSExport("toString")
  @override
  String toString() {
    return genesisBlock;
  }
}
