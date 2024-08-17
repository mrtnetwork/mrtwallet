import 'dart:js_interop';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/web/wallet/event.dart';

import 'events.dart';
import 'tabs.dart';

extension type Runtime._(JSObject _) {
  external factory Runtime();
  external RuntimePort connect(
      String? extensionId, ConnectConnectionInf? connectInfo);
  @JS("openOptionsPage")
  external JSPromise openOptionsPage();
  @JS("sendMessage")
  external JSPromise<JSWalletEvent> sendMessageAsync(
      String? extensionId, JSWalletEvent message, SendMessageOption? options);
  @JS("sendMessage")
  external JSPromise<JSWalletEvent> sendMessageAsync2(JSWalletEvent message);
  @JS("getURL")
  external String getURL(String path);
  @JS("id")
  external String get id;
  @JS("id")
  external String? get idNullabe;
  external LastError? get lastError;
  external JSEvent<
          void Function(
              JSAny? message, MessageSender sender, JSFunction sendResponse)>
      get onMessage;

  external JSEvent<void Function(OnInstalledDetails)> get onInstalled;

  external JSEvent<void Function(RuntimePort port)> get onConnect;

  Future<WalletEvent?> sendMessage_(
      {String? extensionId,
      required WalletEvent message,
      SendMessageOption? options}) async {
    final future =
        sendMessageAsync(extensionId, message.toJsEvent(), options).toDart;
    final result = await future;
    return result.toEvent();
  }

  // Future<WalletEvent?> sendMessage2_({required WalletEvent message}) async {
  //   final future = sendMessageAsync2(message.toJsEvent()).toDart;
  //   final result = await future;
  //   return result.toEvent();
  // }

  Future<JSAny?> openOptionsPage_() async {
    final future = openOptionsPage().toDart;
    return await future;
  }
}

extension type MessageSender._(JSObject _) implements JSAny {
  external final String? documentId;
  external final String? documentLifecycle;
  external final int? frameId;
  external final int? id;
  external final String? nativeApplication;
  external final String? origin;
  external final ChromeTab? tab;
  external final String? tlsChannelId;
  external final String? url;
}
extension type RuntimePort._(JSObject _) implements JSAny {
  external factory RuntimePort();
  external final String name;

  @JS("onDisconnect")
  external final JSEvent<void Function(RuntimePort port)> onDisconnect;

  @JS("onMessage")
  external final JSEvent onMessage;
  external void postMessage(JSAny message);
  external void disconnect();
}

extension type LastError._(JSObject _) implements JSAny {
  external factory LastError();
  external String? get message;
}
extension type ConnectConnectionInf._(JSObject _) implements JSAny {
  external ConnectConnectionInf(
      {bool? includeTlsChannelId, required String name});
  external bool? get includeTlsChannelId;
  external String get name;
}
extension type SendMessageOption._(JSObject _) implements JSAny {
  external bool? get includeTlsChannelId;
  external SendMessageOption({bool? includeTlsChannelId});
}

extension type OnInstalledDetails._(JSObject _) implements JSAny {
  external String? get id;
  external String? get previousVersion;
  external int? get reason;
}
