/// use flutter build web --wasm --csp
/// copy canvakit folder from build/web to web/
/// change "https://www.gstatic.com/flutter-canvaskit/edd8546116457bdf1c5bdfb13ecb9463d2bb5ed4/" in build/web/main.dart.js to "/canvaskit/"
/// update manifest v3 with
///
///  "content_security_policy": {
///       "extension_pages": "script-src 'self' 'wasm-unsafe-eval'; object-src 'self';"
///     },
///     "web_accessible_resources": [{
///       "resources": ["canvaskit/canvaskit.wasm","canvaskit/skwasm.wasm","canvaskit/chromium/canvaskit.wasm"],
///       "matches": ["<all_urls>"]
///     }]
///
/// now we have canvakit extention
///
