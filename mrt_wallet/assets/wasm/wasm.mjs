let _wasmInstance;
let _inited =false;
self.addEventListener('message', async (event) => {
    if(_inited){
        const data = mrtJsHandler(event.data);
        self.postMessage(data);
        return;
    }
  
    let module;
    if (event.module == null) {
        // This is a Chrome extension
        module = await import("./crypto.mjs");
    } else {
        // This is not a Chrome extension
        module = await import("data:text/javascript,".concat(event.data.module));
        // instantiate = module.instantiate;
        // invoke = module.invoke;
    }
    const wasm = await WebAssembly.compile(event.data.wasm);
    // const module = await import("data:text/javascript,".concat(event.data.module))
    _wasmInstance = await module.instantiate(wasm);
    module.invoke(_wasmInstance)
    _inited = true;
    const data = mrtWalletActivation();
    self.postMessage(data);
          
});