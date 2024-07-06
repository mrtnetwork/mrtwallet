let _wasmInstance;
let _inited =false;
self.addEventListener('message', async (event) => {
    if(_inited){
        const data = mrtJsHandler(event.data);
        self.postMessage(data);
        return;
    }
    const wasm = await WebAssembly.compile(event.data.wasm);
    const module = await import("data:text/javascript,".concat(event.data.module))
    _wasmInstance = await module.instantiate(wasm);
    module.invoke(_wasmInstance)
    _inited = true;
    const data = mrtWalletActivation();
    self.postMessage(data);
          
});