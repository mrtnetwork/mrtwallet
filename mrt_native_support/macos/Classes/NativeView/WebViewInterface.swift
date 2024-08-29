import FlutterMacOS
private class WebViewMethods{
    static let webViewFactories = AtomicMap<String, NativeViewFactory>()
    static func getWebView( args: [String: Any?])->NativeViewFactory?{
        guard let id = args["id"] as? String else {
            return nil
        }
        return webViewFactories.value(forKey: id)
    }
    static func initWabViewFactory(channel: FlutterMethodChannel,  args: [String: Any?],registrar:FlutterPluginRegistrar)-> Bool{
        guard let id = args["id"] as? String else {
            return false
        }
        if webViewFactories.value(forKey: id) != nil {
            return false
        }
        let url = args["url"] as? String
        let jsInterface = args["jsInterface"] as? String
        let platformView = NativeViewFactory(channel: channel, id: id, url:url, jsInterface: jsInterface)
        registrar.register(platformView, withId: id)
        
        webViewFactories.setValue(platformView, forKey: id)
        return true
        
    }
    static func removeView( id:String){
        webViewFactories.removeValue(forKey: id)
    }
}


extension MrtNativeSupportPlugin {
    
    public func handle(_ call: FlutterMethodCall,webview result: @escaping FlutterResult){
        guard let args =  call.arguments as? [String:Any],let type = args["type"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid or missing key argument", details: nil))
            return;
        }
        switch type {
        case WebViewConst.createWebView:
            result(WebViewMethods.initWabViewFactory(channel: channel, args:args, registrar: registrar))
            break
        default:
            guard let factory = WebViewMethods.getWebView(args: args) else{
                result(FlutterError(code: "invalid_arguments", message: "webView factory not found", details: nil))
                return
            }
            switch type {
            case WebViewConst.openPage:
                guard let url = args["url"] as? String else {
                    result(FlutterError(code: "invalid_arguments", message: "url missing", details: nil))
                    return;
                }
                factory.openPage(url: url)
                result(true)
                break
            case WebViewConst.addInterface:
                guard let name = args["name"] as? String else {
                    result(FlutterError(code: "invalid_arguments", message: "interface name missing", details: nil))
                    return;
                }
                factory.addMrtJsInterface(name: name)
                result(true)
                break
            case WebViewConst.removeInterface:
                guard let name = args["name"] as? String else {
                    result(FlutterError(code: "invalid_arguments", message: "interface name missing", details: nil))
                    return;
                }
                factory.removeMrtJsInterface(name: name)
                result(true)
                break
            case WebViewConst.canGoForward:
                result(factory.canGoForward())
                break
            case WebViewConst.canGoBack:
                result(factory.canGoBack())
                break
            case WebViewConst.goBack:
                factory.goBack()
                result(nil)
                break
            case WebViewConst.goForward:
                factory.goForward()
                result(nil)
                break
            case WebViewConst.reload:
                factory.reload()
                result(true)
                break
            case WebViewConst.dispose:
                factory.dispose()
                WebViewMethods.removeView(id: factory.id)
                result(nil)
                break
            case WebViewConst.updateFrame:
                guard let width = args["width"] as? CGFloat,
                      let height = args["height"] as? CGFloat else {
                    result(FlutterError(code: "invalid_arguments", message: "width or height missing or invalid", details: nil))
                    return
                }
                factory.updateFrameSize(width: width, height: height)
                result(nil)
                break
            case WebViewConst.injectJavaScript:
                guard let script = args["script"] as? String else {
                    result(FlutterError(code: "invalid_arguments", message: "script missing", details: nil))
                    return;
                }
                factory.injectJavaScript(jsCode: script, completion: { r in
                    result(r)
                }, error: { errorMessage in
                    result(FlutterError(code: "runtime", message: errorMessage, details: nil))
                })
                
                
            default:
                result(FlutterError(code: "invalid_arguments", message: "method not found.", details: nil))
                break
                
            }
            
        }
    }
}

