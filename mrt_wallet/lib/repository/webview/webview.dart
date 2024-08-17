part of 'package:mrt_wallet/repository/repository.dart';

mixin WebViewRepositoryImpl on BaseRepository, CryptoWokerImpl {
  @override
  String get repositoryStorageId => StorageConst.webview;
  Future<void> save(WebViewStorage storage) async {
    await write(
        key: storage.type.storageKey, value: storage.toCbor().toCborHex());
  }

  Future<List<int>?> _getData(String key) async {
    final data = await read(key);
    if (data == null) return null;
    return await crypto.hexToBytes(data).catchError((e) {
      return const <int>[];
    });
  }

  Future<WebViewTabStorage> getTabs() async {
    final data = await _getData(WebViewStorageType.tab.storageKey);
    WebViewTabStorage? storage = MethodUtils.nullOnException(() {
      if (data == null) return null;
      final st = WebViewStorage.deserialize(bytes: data) as WebViewTabStorage;
      return st;
    });
    storage ??= WebViewTabStorage(const []);
    return storage;
  }

  Future<WebViewHistoryStorage> getHistories() async {
    final data = await _getData(WebViewStorageType.hisotry.storageKey);
    WebViewHistoryStorage? storage = MethodUtils.nullOnException(() {
      final st =
          WebViewStorage.deserialize(bytes: data!) as WebViewHistoryStorage;
      return st;
    });
    storage ??= WebViewHistoryStorage(const []);
    return storage;
  }

  Future<WebViewBookmarkStorage> getBookmarks() async {
    final data = await _getData(WebViewStorageType.bookmark.storageKey);
    WebViewBookmarkStorage? storage = MethodUtils.nullOnException(() {
      final st =
          WebViewStorage.deserialize(bytes: data!) as WebViewBookmarkStorage;
      return st;
    });
    storage ??= WebViewBookmarkStorage(const []);
    return storage;
  }
}
