import Cocoa
import FlutterMacOS
import WebKit

class WebViewWrapper: NSView {
    private var webView: WKWebView!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: self.bounds, configuration: webConfiguration)
        webView.autoresizingMask = [.width, .height]
//        webView.allowsBackForwardNavigationGestures = true
        self.addSubview(webView)
        print("was inited!")
        if let url = URL(string: "https://www.google.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
