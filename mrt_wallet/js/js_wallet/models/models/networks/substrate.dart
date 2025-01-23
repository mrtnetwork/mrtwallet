import 'dart:js_interop';
import '../../models.dart';

@JS("substrate")
external set substrate(Proxy? substrate);
@JS("injectedWeb3")
external JSInjectedWeb3 get injectedWeb3;
@JS("injectedWeb3")
external JSInjectedWeb3? get injectedWeb3Nullable;
@JS("injectedWeb3")
external set injectedWeb3(JSInjectedWeb3 _);

extension type SubstrateWalletAdapter(JSObject _) implements MRTNetworkAdapter {
  external set connect(JSFunction f);
  external set signMessage(JSFunction f);
  @JS("signTransaction")
  external set signTransaction(JSFunction f);
  external set metadata(Proxy<JSSubstrateWalletAdapterMetadata> _);
  external set accounts(Proxy<JSSubstrateWalletAdapterAccounts> _);
  external set signer(Proxy<JSSubstrateWalletAdapterSigner> _);
}

extension type JSSubstrateAddress._(JSObject _) implements JSAny {
  external factory JSSubstrateAddress(
      {String address, String? genesisHash, String? name});

  external String get address;
  external String? get genesisHash;
  external String? get name;
}
extension type JSSubstrateAccountsChanged._(JSObject _) implements JSAny {
  external factory JSSubstrateAccountsChanged(
      {JSArray<JSSubstrateAddress> accounts,
      JSSubstrateAddress? defaultAddress});

  external JSArray<JSSubstrateAddress> get accounts;
  external JSSubstrateAddress? get defaultAddress;
}

extension type JSSubstrateProviderConnectInfo._(JSObject _) implements JSAny {
  external factory JSSubstrateProviderConnectInfo({String genesis});
  external String get genesis;
}

extension type JSSubstrateWalletAdapterMetadata(JSObject _) implements JSAny {
  external set get(JSFunction _);
  external set provide(JSFunction _);
}
extension type JSSubstrateWalletAdapterAccounts(JSObject _) implements JSAny {
  @JS("get")
  external set get(JSFunction _);
  @JS("subscribe")
  external set subscribe(JSFunction _);
}

@JS("injectedWeb3")
extension type JSInjectedWeb3(JSObject _) implements JSAny {
  @JS("MRT/0.4.0")
  external set mrt(Proxy? _);
}
extension type JSSubstrateWalletAdapterSigner(JSObject _) implements JSAny {
  @JS("signPayload")
  external set signPayload(JSFunction _);
  @JS("signRaw")
  external set signRaw(JSFunction _);
  @JS("update")
  external set update(JSFunction _);
}

extension type JSSubstrateTransaction(JSObject _) implements JSAny {
  external String get address;
  external String? get assetId;
  external String get blockHash;
  external String get blockNumber;
  external String get era;
  external String get genesisHash;
  external String? get metadataHash;
  external String get method;
  external int? get mode;
  external String get nonce;
  external String get specVersion;
  external String get tip;
  external String get transactionVersion;
  external JSArray<JSString> get signedExtensions;
  external int version;
  external bool? withSignedTransaction;
  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "assetId": assetId,
      "blockHash": blockHash,
      "blockNumber": blockNumber,
      "era": era,
      "genesisHash": genesisHash,
      "metadataHash": metadataHash,
      "method": method,
      "mode": mode,
      "nonce": nonce,
      "specVersion": specVersion,
      "transactionVersion": transactionVersion,
      "tip": tip,
      "signedExtensions": signedExtensions.toDart.map((e) => e.toDart).toList(),
      "version": version,
      "withSignedTransaction": withSignedTransaction
    };
  }
}
extension type JSSubstrateTxResponse._(JSObject _) implements JSAny {
  external factory JSSubstrateTxResponse(
      {int id, String signature, String? signedTransaction});
}
extension type JSSubstrateSign(JSObject _) implements JSAny {
  external String get address;
  external String get type;
  external String get data;
}

extension type JSSubstrateMetadataProvide(JSObject _) implements JSAny {
  external String get chain;
  external String get genesisHash;
  external int get ss58Format;
  external String? get chainType;
  external int get specVersion;
  external int get tokenDecimals;
  external String get tokenSymbol;
  external String? get rawMetadata;
  Map<String, dynamic> toJson() {
    return {
      "chain": chain,
      "genesisHash": genesisHash,
      "ss58Format": ss58Format,
      "chainType": chainType,
      "specVersion": specVersion,
      "tokenDecimals": tokenDecimals,
      "tokenSymbol": tokenSymbol,
      "rawMetadata": rawMetadata
    };
  }
}

extension type JSSubstrateKownMetadata._(JSObject _) implements JSAny {
  external factory JSSubstrateKownMetadata(
      {String genesisHash, int specVersion});
  external String get genesisHash;
  external int get specVersion;
}
