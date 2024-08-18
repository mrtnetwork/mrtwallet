import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';

class WebViewRepository
    with BaseRepository, CryptoWokerImpl, WebViewRepositoryImpl {
  WebViewTabStorage _tabs = WebViewTabStorage(const []);
  WebViewHistoryStorage _histories = WebViewHistoryStorage(const []);
  WebViewBookmarkStorage _bookmarks = WebViewBookmarkStorage(const []);
  List<WebViewTab> get histories => _histories.tabs;
  List<WebViewTab> get bookmarks => _bookmarks.tabs;

  bool inBokmark(WebViewTab tab) {
    return _bookmarks.inBokmark(tab);
  }

  Future<void> initRepository() async {
    _tabs = await getTabs();
    _histories = await getHistories();
    _bookmarks = await getBookmarks();
  }

  WebViewTab? get lastTab => _tabs.getLastObject();

  List<WebViewTab> get tabs => _tabs.tabs;
  Future<void> addOrRemoveFromBookMark(WebViewTab newTab) async {
    _bookmarks.addOrRemoveFromBookMark(newTab);
    await save(_bookmarks);
  }

  Future<void> updateTab(WebViewTab tab) async {
    _tabs.addOrUpdateTab(tab);
    await save(_tabs);
  }

  Future<void> removeTab(WebViewTab tab) async {
    _tabs.removeTab(tab);
    await save(_tabs);
  }

  Future<void> removeHistory(WebViewTab tab) async {
    _histories.remove(tab);
    await save(_histories);
  }

  Future<void> removeBookmark(WebViewTab tab) async {
    _bookmarks.remove(tab);
    await save(_bookmarks);
  }

  Future<void> clearHistory() async {
    _histories.clear();
    await save(_histories);
  }

  Future<void> clearBookmark() async {
    _bookmarks.clear();
    await save(_bookmarks);
  }

  Future<void> saveHistory(WebViewTab tab) async {
    _histories.addNewTab(tab);
    await save(_histories);
  }
}
