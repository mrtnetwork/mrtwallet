import Cocoa
import FlutterMacOS
import Security
import AppKit
import Cocoa
import AVFoundation
import CoreImage

public protocol MethodHandler {
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}
public class MrtNativeSupportPlugin: NSObject, FlutterPlugin,MethodHandler {
    let serviceName = "com.mrtnetwork.mrtwallet"
    public var registrar: FlutterPluginRegistrar!;
    public var channel: FlutterMethodChannel!
    private var barcodeScanner: BarcodeScanner!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.metnetwork.mrt_n.methodChannel", binaryMessenger: registrar.messenger)
        let instance = MrtNativeSupportPlugin(registrar, channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    private var windowManager: WindowManager = WindowManager()
    private var _inited: Bool = false
    private var mainWindow: NSWindow {
        get {
            return (self.registrar.view?.window)!;
        }
    }
    private func ensureInitialized() {
        if (!_inited) {
            windowManager.mainWindow = mainWindow
            windowManager.onEvent = {
                (eventName: String) in
                self._emitEvent(eventName)
            }
            _inited = true
        }
    }
    
    public func _emitEvent(_ eventName: String) {
        let args: NSDictionary = [
            "eventName": eventName,
        ]
        channel.invokeMethod("onEvent", arguments: args, result: nil)
        
    }
    
    public init(_ registrar: FlutterPluginRegistrar, _ channel: FlutterMethodChannel) {
        super.init()
        self.registrar = registrar
        self.channel = channel
        self.barcodeScanner = BarcodeScanner(channel: channel)

        
    }
    
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "webView":
            handle(call, webview:result)
            break
        case "share":
            guard let args =  call.arguments as? [String:Any] else {
                result(FlutterError(code: "invalid_arguments", message: "Invalid or missing key argument", details: nil))
                return;
            }
            let subject = args["subject"]as? String
            let path = args["path"] as? String
            let textToShare = args["text"] as? String
            
            shareText(text: textToShare,subject:subject,path:path, sourceView: mainWindow.contentView) { success, error in
                if let _ = error {
                    result(false)
                } else {
                    if success {
                        result(true)
                    } else {
                        result(false)
                    }
                }
            }
            
            break;
        case "info":
            var keyValues = [String: String]()
            keyValues["device"] = "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                keyValues["app_version"] = appVersion
            }
            keyValues["brand"] = "Apple"
            if let model = getModel(){
                keyValues["model"] = model
            }
            result(keyValues);
            break;
        case "hasBarcodeScanner":
            result(self.barcodeScanner.canStartBarcodeScanner())
            break;
        case "startBarcodeScanner":
            guard let args =  call.arguments as? [String:Any] else {
                result(FlutterError(code: "invalid_arguments", message: "Invalid or missing key argument", details: nil))
                return;
            }
            self.barcodeScanner.checkCameraAccess { granted in
                if !granted {
                    result(FlutterError(code: "CAMERA_PERMISSION_DENIED", message: "Camera access denied", details: nil))
                    return;
                }
            }
            self.barcodeScanner.startBarcodeScanner(result: result,args:args)
            break;
        case "stopBarcodeScanner":
            barcodeScanner.stopBarcodeScanner()
            break;
            
        case "windowsManager":
            guard let args =  call.arguments as? [String:Any],
                  let type = args["type"] as? String else {
                result(FlutterError(code: "invalid_arguments", message: "Invalid or missing key argument", details: nil))
                return;
            }
            switch type {
            case "init":
                ensureInitialized()
                result(_inited)
                break
            case "waitUntilReadyToShow":
                windowManager.waitUntilReadyToShow();
                result(nil)
                break
            case "isFullScreen":
                let isFullScreen = windowManager.isFullScreen()
                result(isFullScreen)
                break
            case "setFullScreen":
                windowManager.setFullScreen(args)
                result(true)
                break
            case "isMaximized":
                let isMaximized = windowManager.isMaximized();
                result(isMaximized)
                break
            case "unmaximize":
                windowManager.unmaximize()
                result(true)
                break
            case "close":
                windowManager.close()
                result(true)
                break
            case "isPreventClose":
                result(windowManager.isPreventClose())
                break
            case "isResizable":
                let isResizable = windowManager.isResizable()
                result(isResizable)
                break
            case "setAsFrameless":
                windowManager.setAsFrameless()
                result(true)
                break
            case "hide":
                windowManager.hide()
                result(true)
                break
            case "show":
                windowManager.show()
                result(true)
                break
            case "setPreventClose":
                windowManager.setPreventClose(args)
                result(true)
                break
            case "focus":
                windowManager.focus()
                result(true)
                break
            case "blur":
                windowManager.blur()
                result(true)
                break
            case "isMinimized":
                let isMinimized = windowManager.isMinimized();
                result(isMinimized)
                break
            case "restore":
                windowManager.restore()
                result(true)
                break
            case "setbounds":
                windowManager.setBounds(args)
                result(true)
                break
            case "getBounds":
                let bounds = windowManager.getBounds()
                result(bounds)
                break
            case "setResizable":
                windowManager.setResizable(args)
                result(true)
                break
            case "maximumSize":
                windowManager.setMaximumSize(args)
                result(true)
                break
            case "minimumSize":
                windowManager.setMinimumSize(args)
                result(true)
                break
            case "isFocused":
                let isFocused = windowManager.isFocused()
                result(isFocused)
                break
            case "isVisible":
                let isVisible = windowManager.isVisible()
                result(isVisible)
                break
            default:
                result(FlutterMethodNotImplemented)
            }
            break
        case "secureStorage":
            guard let args =  call.arguments as? [String:Any],
                  let type = args["type"] as? String else {
                result(FlutterError(code: "invalid_arguments", message: "Invalid or missing key argument", details: nil))
                return;
            }
            switch type {
            case "write":
                if let key: String = args["key"] as? String,
                   let value: String = args["value"] as? String {
                    let s =  saveToKeychain(value: value, forKey: key)
                    result(s)
                    return
                }
                result(false)
                break;
            case "read":
                if let key: String = args["key"] as? String {
                    let r: String? = readFromKeychain(key: key)
                    result(r)
                    return
                }
                result(nil)
                break;
            case "remove":
                if let key: String = args["key"] as? String {
                    let r: Bool = deleteFromKeychain(forKey: key)
                    result(r)
                    return
                }
                result(false)
                break;
            case "containsKey":
                if let key: String = args["key"] as? String {
                    let r: Bool = doesKeyExist(forKey: key)
                    result(r)
                    return
                }
                result(false)
                break;
            case "readMultiple":
                var keyValues = [String: String]()
                if let keys: [String] = args["keys"] as? [String]{
                    for key in keys{
                        let r : String? = readFromKeychain(key: key);
                        if let value = r {
                            keyValues[key] = value
                        }
                    }
                }
                result(keyValues)
                break
            case "removeMultiple":
                var success : Bool = false
                if let keys: [String] = args["keys"] as? [String]{
                    success = true
                    for key in keys{
                        let r : Bool = deleteFromKeychain(forKey: key);
                        if !r {
                            success = false
                        }
                    }
                }
                result(success)
                break
            case "readAll":
                let r = readAllFromKeychain();
                result(r);
                break;
            case "removeAll":
                let r = removeAllKeychainItems();
                result(r);
                break
            default:
                result(FlutterMethodNotImplemented)
                break
            }
            break;
        case "path":
            var keyValues = [String: String]()
            let temporaryDirectoryURL = getTemporaryDirectory()
            keyValues["cache"]=temporaryDirectoryURL.absoluteString;
            let documentsDirectoryURL = getApplicationDocumentsDirectory()
            keyValues["document"]=documentsDirectoryURL.absoluteString;
            let applicationSupportDirectoryURL = getApplicationSupportDirectory()
            keyValues["support"]=applicationSupportDirectoryURL.absoluteString;
            result(keyValues)
        case "lunch_uri":
            guard let args =  call.arguments as? [String:Any],
                  let uri = args["uri"] as? String else {
                result(FlutterError(code: "invalid_arguments", message: "Invalid or missing key argument", details: nil))
                return;
            }
            let res = openURL(uri)
            result(res)
            break;
        case "secureFlag":
            break
        case "init":
            ensureInitialized()
            break
        default:
   
            result(FlutterMethodNotImplemented)
        }
    }
    
    @available(macOS 10.14, *)
    private func startBarcodeScanner(result: FlutterResult, args: [String: Any]) {
        barcodeScanner?.startBarcodeScanner(result: result, args: args)
    }
    
    @available(macOS 10.14, *)
    private func stopBarcodeScanner() {
        barcodeScanner?.stopBarcodeScanner()
    }
    
    func saveToKeychain(value: String, forKey key: String) -> Bool {
        if let data: Data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrService as String: serviceName,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
                
            ]
            
            SecItemDelete(query as CFDictionary)
            
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
        return false
    }
    func readFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!,
            
            
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    func deleteFromKeychain(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: serviceName,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    func readAllFromKeychain() -> [String: String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue!,
        ]
        var keyValues = [String: String]()
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            return keyValues
        }
        let items = result as! Array<Dictionary<String, Any>>
        for item in items {
            if let key = item[kSecAttrAccount as String] as? String,
               let r = readFromKeychain(key: key){
                keyValues[key]=r
            }
        }
        return keyValues
    }
    func removeAllKeychainItems() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue!
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            return true // Deletion successful
        } else {
            return false
        }
    }
    func doesKeyExist(forKey key: String) -> Bool {
        // Create a query to search for the key
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne // Limit to one result
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return true // Key exists in the Keychain
        } else if status == errSecItemNotFound {
            return false // Key not found in the Keychain
        } else {
            return false
        }
    }
    
    func getTemporaryDirectory() -> URL {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        return temporaryDirectoryURL
    }
    
    func getApplicationDocumentsDirectory() -> URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL
    }
    
    func getApplicationSupportDirectory() -> URL {
        let applicationSupportDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return applicationSupportDirectoryURL
    }
    
    func getLibraryDirectory() -> URL {
        let libraryDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        return libraryDirectoryURL
    }
    func openURL(_ urlString: String)-> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        if NSWorkspace.shared.open(url) {
            return true
        }
        return false
    }
    func shareText(text: String?,subject: String?,path:String?, sourceView: NSView?, completion: @escaping (Bool, Error?) -> Void) {
        guard let sourceView = sourceView else {
            completion(false, NSError(domain: "MissingSourceView", code: 0, userInfo: [NSLocalizedDescriptionKey: "Source view is nil"]))
            return
        }
        var sharingItems: [Any] = []
        if let text = text {
            sharingItems.insert(text, at: 0) // Insert subject at the beginning
        }
        if let subject = subject {
            sharingItems.insert(subject, at: 0) // Insert subject at the beginning
        }
        if let path = path {
            sharingItems.append(URL(fileURLWithPath: path))// Insert subject at the beginning
        }
        let sharingServicePicker = NSSharingServicePicker(items: sharingItems)
        sharingServicePicker.show(relativeTo: .zero, of: sourceView, preferredEdge: .minY)
        completion(true,nil)
    }
    func getModel() -> String? {
        var size: size_t = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        
        var model = [CChar](repeating: 0,  count: Int(size))
        sysctlbyname("hw.model", &model, &size, nil, 0)
        
        return String(cString: model)
    }
    
}
