import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/core.dart';

enum WebViewStorageType {
  tab(maxStorageLength: 4, tags: APPSerializationConst.webviewStorageTab),
  hisotry(
      maxStorageLength: 100, tags: APPSerializationConst.webviewStorageHistory),
  bookmark(
      maxStorageLength: 100,
      tags: APPSerializationConst.webviewStorageBookmark);

  const WebViewStorageType(
      {required this.maxStorageLength, required this.tags});
  final int maxStorageLength;
  final List<int> tags;
  static WebViewStorageType fromTag(List<int>? tags) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tags, tags),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  String get storageKey => "_${name}_";
}

abstract class WebViewStorage with CborSerializable {
  abstract final WebViewStorageType type;
  List<WebViewTab> _tabs;
  List<WebViewTab> get tabs => _tabs;
  WebViewStorage(List<WebViewTab> tabs) : _tabs = tabs.imutable;
  factory WebViewStorage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final type = WebViewStorageType.fromTag(tag.tags);
    final objects = tag.getList;
    final tabs = objects
        .elementAt<List<dynamic>>(0)
        .map((e) => WebViewTab.deserialize(object: e))
        .toList();
    tabs.sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    switch (type) {
      case WebViewStorageType.bookmark:
        return WebViewBookmarkStorage(tabs);
      case WebViewStorageType.hisotry:
        return WebViewHistoryStorage(tabs);
      case WebViewStorageType.tab:
        return WebViewTabStorage(tabs);
      default:
        throw WalletExceptionConst.dataVerificationFailed;
    }
  }

  void clear() {
    _tabs = <WebViewTab>[].imutable;
  }

  void remove(WebViewTab tab) {
    if (!_tabs.contains(tab)) return;
    final tabs = List<WebViewTab>.from(_tabs);
    tabs.remove(tab);
    _tabs = tabs.imutable;
  }

  void addNewTab(WebViewTab newTab) {
    final tabs = List<WebViewTab>.from(_tabs);
    tabs.add(newTab);
    tabs.sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    _tabs = tabs.take(type.maxStorageLength).imutable;
  }

  WebViewTab? getLastObject() {
    if (_tabs.isEmpty) return null;
    return _tabs.first;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborListValue.fixedLength(tabs.map((e) => e.toCbor()).toList())]),
        type.tags);
  }
}

class WebViewTabStorage extends WebViewStorage {
  WebViewTabStorage(super.tabs);

  @override
  WebViewStorageType get type => WebViewStorageType.tab;

  void removeTab(WebViewTab removeTab) {
    final tabs = List<WebViewTab>.from(_tabs);
    tabs.removeWhere((e) => e.id == removeTab.id);
    _tabs = tabs.imutable;
  }

  void addOrUpdateTab(WebViewTab newTab) {
    final find = _tabs.indexWhere((e) => e.id == newTab.id);
    if (find < 0) {
      addNewTab(newTab);
      return;
    }

    final tabs = List<WebViewTab>.from(_tabs);
    tabs[find] = newTab;
    tabs.sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    _tabs = List<WebViewTab>.unmodifiable(tabs.take(type.maxStorageLength));
  }
}

class WebViewHistoryStorage extends WebViewStorage {
  WebViewHistoryStorage(super.tabs);

  @override
  WebViewStorageType get type => WebViewStorageType.hisotry;
}

class WebViewBookmarkStorage extends WebViewStorage {
  WebViewBookmarkStorage(super.tabs);

  @override
  WebViewStorageType get type => WebViewStorageType.bookmark;

  bool inBokmark(WebViewTab tab) {
    return tabs.any((e) {
      if (tab.path != null) {
        return e.path == tab.path;
      }
      return tab.url == e.url;
    });
  }

  void addOrRemoveFromBookMark(WebViewTab newTab) {
    final find = _tabs.indexWhere((e) {
      if (newTab.path != null) {
        return e.path == newTab.path;
      }
      return newTab.url == e.url;
    });
    if (find < 0) {
      addNewTab(newTab);
      return;
    }
    final tabs = List<WebViewTab>.from(_tabs);
    tabs.removeAt(find);
    _tabs = tabs.take(type.maxStorageLength).imutable;
  }
}
