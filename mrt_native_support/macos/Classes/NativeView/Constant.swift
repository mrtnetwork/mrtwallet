
struct WebViewConst {
    static let onPageStart: String = "OnPageStart"
    static let onPageError: String = "onPageError"
    static let onPageFinished: String = "onPageFinished"
    static let onPageProgress: String = "onPageProgress"
    static let openPage: String = "openPage"
    static let addInterface: String = "addJsInterface"
    static let removeInterface: String = "removeJsInterface"
    static let createWebView: String = "createWebView"
    static let webView: String = "webView"
    static let injectJavaScript: String = "injectJavaScript"
    static let canGoForward: String = "canGoForward"
    static let canGoBack: String = "canGoBack"
    static let goBack: String = "goBack"
    static let goForward: String = "goForward"
    static let updateFrame: String = "updateFrame"
    static let reload: String = "reload"
    static let dispose: String = "dispose"
    static let request: String = "request"
    static let faviIconScript: String = """
        (function() {
            var links = document.getElementsByTagName('link');
            var favicon = null;
            
            for (var i = 0; i < links.length; i++) {
                var rel = links[i].getAttribute('rel') || '';
                if (rel.includes('icon') || rel.includes('shortcut')) {
                    favicon = links[i].getAttribute('href');
                    if (favicon) {
                        if (!favicon.startsWith('http') && !favicon.startsWith('data:')) {
                            var baseUrl = document.baseURI || document.URL;
                            favicon = new URL(favicon, baseUrl).href;
                        }
                        return favicon;
                    }
                }
            }
            
            var defaultFavicon = document.querySelector('link[rel="icon"]') || document.querySelector('link[rel="shortcut icon"]');
            if (defaultFavicon) {
                favicon = defaultFavicon.getAttribute('href');
                if (favicon) {
                    if (!favicon.startsWith('http') && !favicon.startsWith('data:')) {
                        var baseUrl = document.baseURI || document.URL;
                        favicon = new URL(favicon, baseUrl).href;
                    }
                    return favicon;
                }
            }
            
            return null;
        })()
        """
}
