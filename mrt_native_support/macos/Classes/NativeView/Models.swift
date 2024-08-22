import Foundation
import WebKit

struct WebViewRequest {
    let id: String
    let data: [Int]
    let requestId: String
    let type: String
    
    func toJson() -> [String: Any?] {
        return [
            "client_id": id,
            "data": data,
            "request_id": requestId,
            "type": type
        ]
    }
}

struct WebViewData {
    let id: String
    let eventName: String
    let url: String?
    let favicon: String?
    let originalUrl: String?
    let title: String?
    let message: String?
    let progress: Int?
    let request: WebViewRequest?

    func toJson() -> [String: Any?] {
        return [
            "id": id,
            "eventName": eventName,
            "url": url,
            "favicon": favicon,
            "originalUrl": originalUrl,
            "title": title,
            "message": message,
            "progress": progress,
            "request": request?.toJson()
        ]
    }
}

extension WebViewData {
    static func toJson(
        id: String,
        eventName: String,
        view: WKWebView? = nil,
        message: String? = nil,
        url: String? = nil,
        favicon: String? = nil,
        progress: Int? = nil,
        request: WebViewRequest? = nil
    ) -> WebViewData {
        return WebViewData(
            id: id,
            eventName: eventName,
            url: url ?? view?.url?.absoluteString,
            favicon: favicon,
            originalUrl: view?.url?.absoluteString, // Assuming this is the original URL
            title: view?.title,
            message: message,
            progress: progress,
            request: request
        )
    }
}
