import 'dart:js_interop';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import '../../models.dart';

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

@JS("BN")
extension type JSBN._(JSAny _) implements JSAny {
  external factory JSBN(JSAny val);
  external bool eq(JSAny? other);
}

@JS("solanaWeb3")
external JSAny? get solanaWeb3;
@JS("solana")
external set solana(Proxy? solana);
extension type SolanaWalletAdapter(JSObject _) implements MRTJsObject {
  external set publicKey(JSObject? publicKey);
  external bool get isConnected;
  external set isConnected(bool isConnected);
  external set signMessage(JSFunction f);
  @JS("signAndSendTransaction")
  external set signTransaction(JSFunction f);
  @JS("signAndSendTransaction")
  external set signAndSendTransaction(JSFunction f);

  external set signAllTransactions(JSFunction f);
  @JS("signAndSendAllTransactions")
  external set signAndSendAllTransactions(JSFunction f);

  external set on(JSFunction f);
  external set removeListener(JSFunction f);

  external set connect(JSFunction f);
  factory SolanaWalletAdapter.setup() {
    return SolanaWalletAdapter(JSObject());
  }
}
@JS("Uint8Array")
extension type JSUint8Array(JSAny _) implements JSAny {
  external static JSUint8Array from(JSAny? v);
  external JSUint8Array slice();
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
      {required JSUint8Array signature});
}

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

  List<int> transactionSerialize() {
    final serialize = this.serialize(
        JSSolanaTransactionSerializationConfig(verifySignatures: false));
    return serialize.toListInt();
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

  ///  JSBN(toBytes())
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

  JSAny? get toJSEvent => accounts.jsify();

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

enum SolanaEventTypes {
  accountsChanged([100]),
  chainChanged([101]),
  message([112]),
  connect([113]),
  disconnect([114]),
  active([115]),
  disable([116]);

  final List<int> tag;
  const SolanaEventTypes(this.tag);
  static SolanaEventTypes fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static SolanaEventTypes? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

class ClientMessageSolana extends PageMessage {
  const ClientMessageSolana({required super.method, super.params});

  factory ClientMessageSolana.event(SolanaEventTypes event) {
    return ClientMessageSolana(method: event.name, params: null);
  }
  @override
  JSClientType get type => JSClientType.solana;

  factory ClientMessageSolana.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        tags: JSClientType.solana.tag,
        hex: cborHex,
        object: object);
    final params = StringUtils.toJson(values.elementAt(1));
    return ClientMessageSolana(
        method: values.elementAt(0), params: params["result"]);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method,
          StringUtils.fromJson({"result": params})
        ]),
        type.tag);
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

class JSWalletMessageResponseSolana extends JSWalletNetworkEvent {
  JSWalletMessageResponseSolana({
    required this.event,
    super.data,
  }) : super(client: JSClientType.solana);
  final SolanaEventTypes event;
  factory JSWalletMessageResponseSolana.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: JSWalletMessageType.event.tag);
    final client = JSClientType.fromTag(values.elementAt(0));
    if (client != JSClientType.solana) {
      throw Web3RequestExceptionConst.internalError;
    }
    return JSWalletMessageResponseSolana(
        event: SolanaEventTypes.fromTag(values.elementAt(1)),
        data: StringUtils.toJson(values.elementAt<String>(2))["result"]);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(client.tag),
          CborBytesValue(event.tag),
          resultAsJsonString
        ]),
        type.tag);
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

@JS("SolanaRequestParams")
extension type SolanaRequestParams._(JSObject o)
    implements Web3JSRequestParams {
  external factory SolanaRequestParams({String? method, JSAny? params});
  external String get method;
  external set method(String? method);
  external JSAny? get params;
}
