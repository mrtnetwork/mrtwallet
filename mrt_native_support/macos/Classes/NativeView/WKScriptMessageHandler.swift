import WebKit
import FlutterMacOS

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    private let viewType: String
    private let channel: FlutterMethodChannel
    private let webView: WKWebView
    
    init(viewType: String, channel: FlutterMethodChannel,webview:WKWebView) {
        self.viewType = viewType
        self.channel = channel
        self.webView = webview
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? [String: Any],
              let id = messageBody["id"] as? String,
              let dataHex = messageBody["data"] as? String,  // Change here
              let requestId = messageBody["requestId"] as? String,
              let type = messageBody["type"] as? String else {
            return
        }
        switch type {
        case "log":
            channel.invokeMethod(WebViewConst.webView, arguments: messageBody)
            return
        default:
            break
        }
        
        let data = hexStringToBytes(dataHex)
        let request = WebViewRequest(id: id, data: data, requestId: requestId, type: type)
        
        let json = WebViewData.toJson(id: self.viewType, eventName: WebViewConst.request, view: self.webView, request: request)
        channel.invokeMethod(WebViewConst.webView, arguments: json.toJson())
    }
    func hexStringToBytes(_ hexString: String) -> [Int] {
        var bytes: [Int] = []
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            if let byte = Int(hexString[index..<nextIndex], radix: 16) {
                bytes.append(byte)
            }
            index = nextIndex
        }
        
        return bytes
    }
}
