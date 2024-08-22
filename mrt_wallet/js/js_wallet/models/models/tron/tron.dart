import 'dart:js_interop';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import '../ethreum/ethereum.dart';
import '../requests.dart';

@JS()
extension type TronJSWalletAdapter(JSObject _) implements JSObject {
  external TronJSLinkWallet get tronWeb;
  external set tronWeb(TronJSLinkWallet tronWeb);
  external set request(JSFunction f);
  external set isTronLink(bool isTronLink);
  external set on(JSFunction f);
  external set removeListener(JSFunction f);
  @JS("request")
  external JSPromise<JSAny?> requestPromis(TronRequestParams params);
}
@JS("TronRequestInterface")
extension type TronRequestParams._(JSObject o)
    implements EthereumRequestParams {}

@JS()
extension type TronJSWalletTRX(JSObject _) implements MRTJsObject {
  external JSPromise<JSAny> multiSign(JSArray<JSAny> args);
  external JSPromise<JSAny> signTransaction(
      JSAny transaction, String? privateKey);
  @JS("signTransaction")
  external set signTransaction_(JSFunction f);

  external JSPromise<JSString> signMessageV2(
      String message, String? privateKey);
  @JS("signMessageV2")
  external set signMessageV2_(JSFunction f);
}

@JS()
extension type TronJSLinkWallet(JSObject _) implements MRTJsObject {
  external TronJSWalletTRX get trx;
  external set trx(TronJSWalletTRX? defaultAddress);
  external String? get defaultAddress;
  external set defaultAddress(String? defaultAddress);
}

enum TronEventTypes {
  accountsChanged([110]),
  chainChanged([111]),
  message([112]),
  connect([113]),
  disconnect([114]),
  active([115]),
  disable([116]);

  final List<int> tag;
  const TronEventTypes(this.tag);
  static TronEventTypes fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static TronEventTypes? fromName(String? name) {
    try {
      return values.firstWhere((e) => e.name == name,
          orElse: () => throw Web3RequestExceptionConst.internalError);
    } catch (e) {
      return null;
    }
  }
}

class ClientMessageTron extends ClientMessage {
  const ClientMessageTron(
      {required super.method, required super.params, required super.id});
  factory ClientMessageTron.event(
      {required EthereumEvnetTypes event, required String requestId}) {
    return ClientMessageTron(method: event.name, params: null, id: requestId);
  }
  @override
  JSClientType get type => JSClientType.tron;

  factory ClientMessageTron.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        tags: JSClientType.tron.tag,
        hex: cborHex,
        object: object);
    final params = StringUtils.toJson(values.elementAt(1));
    return ClientMessageTron(
        method: values.elementAt(0),
        params: params["result"],
        id: values.elementAt(2));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method,
          StringUtils.fromJson({"result": params}),
          id,
        ]),
        type.tag);
  }
}
