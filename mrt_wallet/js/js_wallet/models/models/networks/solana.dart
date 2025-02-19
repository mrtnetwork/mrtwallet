import 'dart:js_interop';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import '../../../utils/utils/extensions.dart';
import '../../models.dart';

class SolanaJSConstant {
  static const String version = '1.0.0';
  static final JSArray<JSAny> solanaTransactionVersion =
      ['legacy'.toJS, 0.toJS].toJS;
  static final JSArray<JSString> solanaDefaultAccountFeatures = [
    "solana:signAndSendTransaction".toJS,
    "solana:signTransaction".toJS,
    "solana:signMessage".toJS,
    "solana:signIn".toJS,
  ].toJS;
  static final JSArray<JSString> supportedChains = [
    "solana:mainnet".toJS,
    "solana:devnet".toJS,
    "solana:testnet".toJS,
  ].toJS;
  static const String walletStandardRegisterEvent =
      "wallet-standard:register-wallet";
  static const String walletStandardAppReadyEvent = "wallet-standard:app-ready";
}

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
  external JSObject? get publicKey;
  external JSArray<JSSolanaWalletAccount> get accounts;
  external set accounts(JSArray<JSSolanaWalletAccount> accounts);
  external bool get isConnected;
  external set isConnected(bool isConnected);
  external set connect(JSFunction f);

  external set signMessage(JSFunction f);
  @JS("signTransaction")
  external set signTransaction(JSFunction f);
  @JS("signAndSendTransaction")
  external set signAndSendTransaction(JSFunction f);

  @JS("sendTransaction ")
  external set sendTransaction(JSFunction f);
  @JS("signAllTransactions")
  external set signAllTransactions(JSFunction f);
  @JS("features")
  external Proxy<SolanaWalletAdapterFeatures> get features;
  @JS("features")
  external set features(Proxy<SolanaWalletAdapterFeatures> features);

  external set chains(JSArray<JSString> _);

  external set on(JSFunction f);
  external set removeListener(JSFunction f);

  factory SolanaWalletAdapter.setup() {
    return SolanaWalletAdapter(JSObject());
  }

  void update(SolanaAccountsChanged account) {
    selectedAddress = account.defaultAddress?.base58.toJS;
    publicKey = account.defaultAddress?.toJSPublicKey()?.toJS;
    accounts = account.accounts.map((e) => e.toJS).toList().toJS.freez;
    isConnected = publicKey != null;
  }
}

@JS("Uint8Array")
extension type APPJSUint8Array(JSAny _) implements JSAny {
  external static APPJSUint8Array from(JSAny? v);
  @JS("from")
  external static JSFunction? get from_;
  external APPJSUint8Array slice();
  factory APPJSUint8Array.fromList(List<int> bytes) {
    return APPJSUint8Array.from(bytes.jsify());
  }
  List<int> toListInt() {
    return (dartify() as List?)?.cast() ?? [];
  }
}
@JS()
extension type StandardWalletAdapterRegisterEvent(JSAny _) implements JSAny {
  external JSAny register(JSAny wallet);
}

@JS()
extension type SolanaWalletAdapterFeatures(JSAny _) implements JSAny {
  factory SolanaWalletAdapterFeatures.setup() {
    return SolanaWalletAdapterFeatures(JSObject());
  }
  @JS("standard:connect")
  external set connect(SolanaWalletAdapterStandardConnectFeature _);

  @JS("standard:events")
  external set events(SolanaWalletAdapterStandardEventsFeature _);

  @JS("solana:signAndSendTransaction")
  external set signAndSendTransaction(
      SolanaWalletAdapterSolanaSignAndSendTransactionFeature _);

  @JS("solana:signTransaction")
  external set signTransaction(
      SolanaWalletAdapterSolanaSignTransactionFeature _);

  @JS("solana:signMessage")
  external set signMessage(SolanaWalletAdapterSolanaSignMessageFeature _);
}
@JS("standard:connect")
extension type SolanaWalletAdapterStandardConnectFeature(JSAny _)
    implements JSAny {
  factory SolanaWalletAdapterStandardConnectFeature.setup(
      {required JSFunction connect,
      String version = SolanaJSConstant.version}) {
    return SolanaWalletAdapterStandardConnectFeature(JSObject())
      ..connect = connect
      ..version = version;
  }
  external set version(String version);
  external set connect(JSFunction _);
}
@JS("standard:events")
extension type SolanaWalletAdapterStandardEventsFeature(JSAny _)
    implements JSAny {
  factory SolanaWalletAdapterStandardEventsFeature.setup(
      {required JSFunction on, String version = SolanaJSConstant.version}) {
    return SolanaWalletAdapterStandardEventsFeature(JSObject())
      ..on = on
      ..version = version;
  }
  external set version(String version);
  external set on(JSFunction _);
}
@JS("solana:signAndSendTransaction")
extension type SolanaWalletAdapterSolanaSignAndSendTransactionFeature(JSAny _)
    implements JSAny {
  factory SolanaWalletAdapterSolanaSignAndSendTransactionFeature.setup(
      {required JSFunction signAndSendTransaction,
      required JSArray supportedTransactionVersions,
      String version = SolanaJSConstant.version}) {
    return SolanaWalletAdapterSolanaSignAndSendTransactionFeature(JSObject())
      ..signAndSendTransaction = signAndSendTransaction
      ..version = version
      ..supportedTransactionVersions = supportedTransactionVersions;
  }
  external set version(String version);
  external set supportedTransactionVersions(JSArray _);
  external set signAndSendTransaction(JSFunction _);
}
@JS("solana:signTransaction")
extension type SolanaWalletAdapterSolanaSignTransactionFeature(JSAny _)
    implements JSAny {
  factory SolanaWalletAdapterSolanaSignTransactionFeature.setup(
      {required JSFunction signTransaction,
      required JSArray supportedTransactionVersions,
      String version = SolanaJSConstant.version}) {
    return SolanaWalletAdapterSolanaSignTransactionFeature(JSObject())
      ..signTransaction = signTransaction
      ..version = version
      ..supportedTransactionVersions = supportedTransactionVersions;
  }
  external set version(String version);
  external set supportedTransactionVersions(JSArray _);
  external set signTransaction(JSFunction _);
}
@JS("solana:signMessage")
extension type SolanaWalletAdapterSolanaSignMessageFeature(JSAny _)
    implements JSAny {
  factory SolanaWalletAdapterSolanaSignMessageFeature.setup(
      {required JSFunction signMessage,
      String version = SolanaJSConstant.version}) {
    return SolanaWalletAdapterSolanaSignMessageFeature(JSObject())
      ..signMessage = signMessage
      ..version = version;
  }
  external set version(String version);
  external set signMessage(JSFunction _);
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
      {required APPJSUint8Array signature,
      required JSObject publicKey,
      required APPJSUint8Array signedMessage});
  external APPJSUint8Array get signature;
  external JSObject get publicKey;
  external APPJSUint8Array get signedMessage;

  factory JSSolanaSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return JSSolanaSignMessageResponse(
        signature: APPJSUint8Array.fromList((json["signature"] as List).cast()),
        signedMessage:
            APPJSUint8Array.fromList((json["signedMessage"] as List).cast()),
        publicKey: JSSolanaPublicKey(
                base58: json["signer"],
                bytes: (json["signerAddressBytes"] as List).cast())
            .toJS);
  }
}

class JSSolanaSignTransactionResponse {
  final List<int> signature;
  final List<int> addressBytes;
  final List<int> serializedTx;
  final String address;
  JSSolanaSignTransactionResponse(
      {required List<int> signature,
      required List<int> addressBytes,
      required List<int> signedTx,
      required this.address})
      : signature = signature.asImmutableBytes,
        addressBytes = addressBytes.asImmutableBytes,
        serializedTx = signedTx.asImmutableBytes;
  factory JSSolanaSignTransactionResponse.fromJson(Map<String, dynamic> json) {
    return JSSolanaSignTransactionResponse(
        signature: (json["signature"] as List).cast(),
        addressBytes: (json["signerAddressBytes"] as List).cast(),
        address: json["signer"],
        signedTx: (json["serializedTx"] as List).cast());
  }
  JSSolanaPublicKey get signerPubKey =>
      JSSolanaPublicKey(base58: address, bytes: addressBytes);
}

extension type JSSolanaTranasctionSendOptions2._(JSObject _) implements JSAny {
  external factory JSSolanaTranasctionSendOptions2(bool? skipPreflight,
      String? preflightCommitment, int? minContextSlot, int? maxRetries);
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

enum JSSolanalaTransactionType {
  web3,
  walletAdapter;

  static JSSolanalaTransactionType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw throw Web3RequestExceptionConst.internalError);
  }
}

extension type SolanaSignTransactionOutput._(JSObject _) implements JSAny {
  external factory SolanaSignTransactionOutput(
      {APPJSUint8Array signedTransaction});

  external APPJSUint8Array get signedTransaction;
}
extension type SolanaSignAndSendTransactionOutput._(JSObject _)
    implements JSAny {
  external factory SolanaSignAndSendTransactionOutput({JSAny signature});
  external JSAny get signature;
}

extension type JSSolanaTransaction(JSObject _) implements JSAny {
  external set txType(String? _);
  external String? get txType;
  external JSSolanaTranasctionSendOptions? get options;
  external set options(JSSolanaTranasctionSendOptions? _);
  JSSolanalaTransactionType get type =>
      JSSolanalaTransactionType.fromName(txType);
  JSAny toResponse(
      {required JSSolanaPublicKey signer,
      required List<int> signature,
      required List<int> signedTransaction}) {
    final type = this.type;
    switch (type) {
      case JSSolanalaTransactionType.walletAdapter:
        return SolanaSignTransactionOutput(
            signedTransaction: APPJSUint8Array.fromList(signedTransaction));
      case JSSolanalaTransactionType.web3:
        final SolanaWeb3Transaction tx = this as SolanaWeb3Transaction;
        tx.addSignature(signer.toJS, APPJSUint8Array.fromList(signature));
        return this;
    }
  }

  APPJSUint8Array transactionSerialize() {
    final type = this.type;
    switch (type) {
      case JSSolanalaTransactionType.walletAdapter:
        final SolanaWalletAdapterStandardTransaction tx =
            this as SolanaWalletAdapterStandardTransaction;
        return tx.transaction;
      case JSSolanalaTransactionType.web3:
        final SolanaWeb3Transaction tx = this as SolanaWeb3Transaction;
        return tx.transactionSerialize();
    }
  }
}
extension type SolanaWeb3Transaction(JSObject _)
    implements JSSolanaTransaction {
  external set serializedBytes(APPJSUint8Array _);
  external APPJSUint8Array get serializedBytes;
  external APPJSUint8Array serialize(
      JSSolanaTransactionSerializationConfig? config);
  external void addSignature(JSObject pubkey, JSAny? signature);
  APPJSUint8Array transactionSerialize() {
    return serializedBytes;
  }

  static SolanaWeb3Transaction? fromJSAny(JSAny? object) {
    try {
      /// ['signatures', 'message']
      /// feePayer, instructions, recentBlockhash, lastValidBlockHeight, nonceInfo, minNonceContextSlot
      final tx = object as SolanaWeb3Transaction;
      return tx
        ..txType = JSSolanalaTransactionType.web3.name
        ..serializedBytes = tx.serialize(
            JSSolanaTransactionSerializationConfig(verifySignatures: false));
    } catch (e) {
      return null;
    }
  }
}
extension type SolanaWalletAdapterSignMessage(JSObject _) implements JSAny {
  external JSSolanaWalletAccount get account;
  external APPJSUint8Array get message;

  static SolanaWalletAdapterSignMessage? fromJSAny(JSAny? object) {
    final message = MRTJsObject.as<SolanaWalletAdapterSignMessage>(
        object: object, keys: ['account', 'message']);
    return message;
  }
}
extension type SolanaWalletAdapterStandardTransaction(JSObject _)
    implements JSSolanaTransaction {
  external JSSolanaWalletAccount? get account;
  external APPJSUint8Array get transaction;
  external set transaction(APPJSUint8Array _);
  external String? get chain;

  static SolanaWalletAdapterStandardTransaction? fromJSAny(JSAny? object) {
    final tx = MRTJsObject.as<SolanaWalletAdapterStandardTransaction>(
        object: object, keys: ['account', 'transaction']);
    return tx?..txType = JSSolanalaTransactionType.walletAdapter.name;
  }

  Map<String, dynamic> toJson() {
    return {
      "account": account?.toJson(),
      "transaction": transaction.toListInt(),
      "chain": chain,
      "options": options?.toJson()
    };
  }
}

extension type SolanaWeb3JSPubKey._(JSObject _) implements JSAny {
  @JS("_bn")
  external JSAny? get _bn;
  external bool equals(JSAny? other);
}

class JSSolanaPublicKey {
  final String base58;
  final APPJSUint8Array bytes;
  const JSSolanaPublicKey._(this._bn,
      {required this.base58, required this.bytes});
  factory JSSolanaPublicKey(
      {required String base58, required List<int> bytes}) {
    final jsBuffer = APPJSUint8Array.from(bytes.jsify());
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
  APPJSUint8Array toBytes() {
    return bytes.slice();
  }

  JSObject get toJS => createJSInteropWrapper(this);
}

extension type JSSolanaWalletAccount._(JSObject _) implements JSAny {
  factory JSSolanaWalletAccount.setup() {
    return JSSolanaWalletAccount._(JSObject());
  }
  external set address(String address);
  external String get address;
  external APPJSUint8Array get publicKey;
  external JSArray<JSString>? get chains;
  external JSArray<JSString>? get features;
  external set publicKey(APPJSUint8Array bytes);
  external set chains(JSArray<JSString>? chains);
  external set features(JSArray<JSString>? features);
  external set label(String? _);
  external set icon(String? _);

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "publicKey": publicKey.toListInt(),
      "chains": chains?.toDart.map((e) => e.toDart).toList(),
      "features": features?.toDart.map((e) => e.toDart).toList(),
    };
  }
}

class SolanaWalletAccount {
  final String base58;
  final List<int> bytes;
  final List<String> chains;
  final List<String> features;

  SolanaWalletAccount._(
      {required this.base58,
      required this.bytes,
      required List<String> chains,
      required List<String> features})
      : chains = chains.immutable,
        features = features.immutable;
  factory SolanaWalletAccount(
      {required String base58,
      required List<int> bytes,
      required List<String> chains,
      required List<String> features}) {
    return SolanaWalletAccount._(
        base58: base58, bytes: bytes, chains: chains, features: features);
  }
  factory SolanaWalletAccount.fromJson(Map<String, dynamic> json) {
    return SolanaWalletAccount(
        base58: json["base58"],
        bytes: (json["bytes"] as List).cast(),
        chains: (json["chains"] as List).cast(),
        features: (json["features"] as List).cast());
  }
  Map<String, dynamic> toJson() {
    return {
      "base58": base58,
      "bytes": bytes,
      "features": features,
      "chains": chains
    };
  }

  JSSolanaPublicKey? toJSPublicKey() {
    return JSSolanaPublicKey(base58: base58, bytes: bytes);
  }

  JSSolanaWalletAccount get toJS {
    return JSSolanaWalletAccount.setup()
      ..address = base58
      ..chains = chains.map((e) => e.toJS).toList().toJS.freez
      ..features = SolanaJSConstant.solanaDefaultAccountFeatures.freez
      ..publicKey = APPJSUint8Array.fromList(bytes);
  }
}

class SolanaAccountsChanged {
  final List<SolanaWalletAccount> accounts;
  final SolanaWalletAccount? defaultAddress;

  final SolanaProviderConnectInfo connectInfo;
  SolanaAccountsChanged({
    required List<SolanaWalletAccount> accounts,
    required this.defaultAddress,
    required this.connectInfo,
  }) : accounts = accounts.imutable;
  factory SolanaAccountsChanged.fromJson(Map<String, dynamic> json) {
    return SolanaAccountsChanged(
        accounts: (json["accounts"] as List)
            .map((e) => SolanaWalletAccount.fromJson((e as Map).cast()))
            .toList(),
        defaultAddress: json["defaultAddress"] == null
            ? null
            : SolanaWalletAccount.fromJson(json["defaultAddress"]),
        connectInfo: SolanaProviderConnectInfo.fromJson(json["connectInfo"]));
  }
  Map<String, dynamic> toJson() {
    return {
      "accounts": accounts.map((e) => e.toJson()).toList(),
      "defaultAddress": defaultAddress?.toJson(),
      "connectInfo": connectInfo.toJson()
    };
  }

  // JSAny? get accountJS => accounts.map((e) => e.toJS).toList().toJS;

  JSSolanaPublicKey? toJSPublicKey() {
    return defaultAddress?.toJSPublicKey();
  }

  StandardEventsChangeProperties toChangeEvent() {
    return StandardEventsChangeProperties(chains: null, accounts: accounts);
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
  final String name;

  SolanaProviderConnectInfo({required this.genesisBlock, required this.name});
  factory SolanaProviderConnectInfo.fromJson(Map<String, dynamic> json) {
    return SolanaProviderConnectInfo(
        genesisBlock: json["genesisBlock"], name: json["name"]);
  }
  Map<String, dynamic> toJson() {
    return {"genesisBlock": genesisBlock, "name": name};
  }

  StandardEventsChangeProperties toChangeEvent() {
    return StandardEventsChangeProperties(chains: [name], accounts: null);
  }

  JSAny? get toJS => createJSInteropWrapper(this);
  @JSExport("toString")
  @override
  String toString() {
    return genesisBlock;
  }
}

extension type JSStandardEventsChangeProperties._(JSObject _) implements JSAny {
  factory JSStandardEventsChangeProperties.setup() {
    return JSStandardEventsChangeProperties._(JSObject());
  }
  external set chains(JSArray<JSString>? chains);
  external set accounts(JSArray<JSSolanaWalletAccount>? accounts);
}

class StandardEventsChangeProperties {
  final List<String>? chains;
  final List<SolanaWalletAccount>? accounts;
  StandardEventsChangeProperties({
    required List<String>? chains,
    required List<SolanaWalletAccount>? accounts,
  })  : chains = chains?.immutable,
        accounts = accounts?.immutable;
  JSStandardEventsChangeProperties toJS() {
    return JSStandardEventsChangeProperties.setup()
      ..chains = chains?.map((e) => e.toJS).toList().toJS
      ..accounts = accounts?.map((e) => e.toJS).toList().toJS;
  }
}
