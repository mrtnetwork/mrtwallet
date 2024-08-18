import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_native_support/models/events/events.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

extension type Tabs._(JSObject _) {
  @JS("query")
  external void query(QueryInfo queryInfo, JSFunction? tab);
  external JSPromise<ChromeTab> get(int tabId);
  @JS("query")
  external JSPromise<JSArray<ChromeTab>> queryAsync(QueryInfo queryInfo);
  @JS("connect")
  external RuntimePort connect(int tabId, ConnectionInfo? connectInfo);

  @JS("create")
  external RuntimePort create(
      CreateTabProperties? createProperties, JSFunction? callback);

  @JS("sendMessage")
  external JSPromise<JSWalletEvent> sendMessageAsync(
      int tabId, JSWalletEvent message, TabSendMessageOptions? options);

  external JSEvent<void Function(ActiveInfo activeInfo)> get onActivated;
  external JSEvent<
          void Function(int tabId, ChangeInfo changeInfo, ChromeTab tab)>
      get onUpdated;

  Future<ChromeTab> get_(int tabId) async {
    final future = get(tabId).toDart;
    final result = await future;
    return result;
  }

  Future<List<ChromeTab>> query_(
      {bool? active,
      bool? audible,
      bool? autoDiscardable,
      bool? currentWindow,
      bool? discarded,
      // int? groupId,
      bool? highlighted,
      int? index,
      bool? lastFocusedWindow,
      bool? muted,
      bool? pinned,
      int? windowId,
      String? windowType,
      List<String>? urls,
      String? host}) async {
    JSAny? url;
    if (urls != null) {
      if (urls.length == 1) {
        url = urls.first.toJS;
      } else {
        url = urls.map((e) => e.toJS).toList().toJS;
      }
    } else if (host != null) {
      final uri = Uri.parse(host);
      host = uri.host;
      if (uri.hasPort) {
        host = "$host:${uri.port}";
      }
      if (jsWindow.navigator.isFirefox) {
        host = "*://$host/*";
      } else {
        host = "${uri.scheme}://$host/*";
      }
      url = host.toJS;
    }

    final future = queryAsync(QueryInfo(
            active: active,
            audible: audible,
            autoDiscardable: autoDiscardable,
            currentWindow: currentWindow,
            discarded: discarded,
            // groupId: groupId,
            highlighted: highlighted,
            index: index,
            lastFocusedWindow: lastFocusedWindow,
            muted: muted,
            pinned: pinned,
            windowId: windowId,
            url: url))
        .toDart;
    final result = await future;
    return result.toDart;
  }

  Future<WalletEvent?> sendMessage_(
      {required int tabId,
      required JSWalletEvent message,
      TabSendMessageOptions? option}) async {
    final data = sendMessageAsync(tabId, message, option).toDart;
    return (await data).toEvent();
  }
}
extension type ChromeTab._(JSObject _) implements JSAny {
  external factory ChromeTab();
  external bool active;
  external bool? audible;
  external bool autoDiscardable;
  external bool discarded;
  external String? favIconUrl;
  // external int groupId;
  external int? height;
  external bool highlighted;
  external int? id;
  external bool incognito;
  external int index;
  external int? lastAccessed;
  external String? title;
  external String? url;
}

extension type QueryInfo._(JSObject o) implements JSObject {
  external QueryInfo(
      {bool? active,
      bool? audible,
      bool? autoDiscardable,
      bool? currentWindow,
      bool? discarded,
      // int? groupId,
      bool? highlighted,
      int? index,
      bool? lastFocusedWindow,
      bool? muted,
      bool? pinned,
      int? windowId,
      String? windowType,
      JSAny? url});
  external bool? get active;
  external bool? get audible;
  external bool? get autoDiscardable;
  external bool? get currentWindow;
  external bool? get discarded;
  // external int? get groupId;
  external bool? get highlighted;
  external int? get index;
  external bool? get lastFocusedWindow;
  external bool? get muted;
  external bool? get pinned;
  external int? get windowId;
  external String? get windowType;
  external JSAny? get url;
}
extension type ActiveInfo._(JSObject o) implements JSObject {
  external factory ActiveInfo();
  external int get tabId;
  external int get windowId;
}
extension type ChangeInfo._(JSObject o) implements JSObject {
  external factory ChangeInfo();
  external bool? get audible;
  external bool? get autoDiscardable;
  external bool? get discarded;
  external String? get favIconUrl;
  // external int? get groupId;
  external String? get mutedInfo;
  external bool? get pinned;
  external String? get status;
  external String? get title;
  external String? get url;
}

extension type ConnectionInfo._(JSObject o) implements JSObject {
  external ConnectionInfo({String? documentId, int? frameId, String? name});
  external String? get documentId;
  external int? get frameId;
  external String? get name;
}
extension type CreateTabProperties._(JSObject o) implements JSObject {
  external CreateTabProperties(
      {bool? active,
      int? index,
      int? openerTabId,
      bool? pinned,
      String? url,
      int? windowId});
  external bool? get active;
  external int? get index;
  external int? get openerTabId;
  external bool? get pinned;
  external String? get url;
  external int? get windowId;
}
@JS()
extension type TabSendMessageOptions._(JSObject o) implements JSObject {
  external TabSendMessageOptions({String? documentId, String? frameId});
  external String? get documentId;
  external String? get frameId;
}
