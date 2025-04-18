
// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  async instantiate(additionalImports, {loadDeferredWasm} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + js;
    }

    // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
      const exports = dartInstance.exports;
      const read = exports.$listRead;
      const length = exports.$listLength(list);
      const array = new constructor(length);
      for (let i = 0; i < length; i++) {
        array[i] = read(list, i);
      }
      return array;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {

      _11: x0 => new Array(x0),
      _13: x0 => x0.length,
      _15: (x0,x1) => x0[x1],
      _16: (x0,x1,x2) => x0[x1] = x2,
      _19: (x0,x1,x2) => new DataView(x0,x1,x2),
      _21: x0 => new Int8Array(x0),
      _22: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _23: x0 => new Uint8Array(x0),
      _29: x0 => new Uint16Array(x0),
      _33: x0 => new Uint32Array(x0),
      _35: x0 => new Float32Array(x0),
      _37: x0 => new Float64Array(x0),
      _43: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._43(f,arguments.length,x0) }),
      _44: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._44(f,arguments.length,x0) }),
      _70: (decoder, codeUnits) => decoder.decode(codeUnits),
      _71: () => new TextDecoder("utf-8", {fatal: true}),
      _72: () => new TextDecoder("utf-8", {fatal: false}),
      _80: Date.now,
      _82: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _83: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _84: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _104: s => JSON.stringify(s),
      _105: s => printToConsole(s),
      _106: a => a.join(''),
      _107: (o, a, b) => o.replace(a, b),
      _109: (s, t) => s.split(t),
      _110: s => s.toLowerCase(),
      _111: s => s.toUpperCase(),
      _112: s => s.trim(),
      _115: (s, n) => s.repeat(n),
      _116: (s, p, i) => s.indexOf(p, i),
      _117: (s, p, i) => s.lastIndexOf(p, i),
      _118: (s) => s.replace(/\$/g, "$$$$"),
      _119: Object.is,
      _120: s => s.toUpperCase(),
      _121: s => s.toLowerCase(),
      _122: (a, i) => a.push(i),
      _130: (a, s, e) => a.slice(s, e),
      _132: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _133: a => a.length,
      _135: (a, i) => a[i],
      _136: (a, i, v) => a[i] = v,
      _138: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _139: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _140: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _141: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _142: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _143: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _144: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _145: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _148: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _149: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _151: l => new DataView(new ArrayBuffer(l)),
      _152: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _154: o => o.buffer,
      _155: o => o.byteOffset,
      _156: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _157: (b, o) => new DataView(b, o),
      _158: (b, o, l) => new DataView(b, o, l),
      _159: Function.prototype.call.bind(DataView.prototype.getUint8),
      _160: Function.prototype.call.bind(DataView.prototype.setUint8),
      _161: Function.prototype.call.bind(DataView.prototype.getInt8),
      _162: Function.prototype.call.bind(DataView.prototype.setInt8),
      _163: Function.prototype.call.bind(DataView.prototype.getUint16),
      _164: Function.prototype.call.bind(DataView.prototype.setUint16),
      _165: Function.prototype.call.bind(DataView.prototype.getInt16),
      _166: Function.prototype.call.bind(DataView.prototype.setInt16),
      _167: Function.prototype.call.bind(DataView.prototype.getUint32),
      _168: Function.prototype.call.bind(DataView.prototype.setUint32),
      _169: Function.prototype.call.bind(DataView.prototype.getInt32),
      _170: Function.prototype.call.bind(DataView.prototype.setInt32),
      _175: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _176: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _177: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _178: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _180: () => ({}),
      _195: x0 => globalThis.postMessage(x0),
      _196: x0 => globalThis.postMessage(x0),
      _197: x0 => globalThis.mrtJsHandler = x0,
      _198: x0 => globalThis.mrtWalletActivation = x0,
      _199: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._199(f,arguments.length,x0) }),
      _200: f => finalizeWrapper(f, function() { return dartInstance.exports._200(f,arguments.length) }),
      _202: (x0,x1) => new Worker(x0,x1),
      _203: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._203(f,arguments.length,x0) }),
      _204: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _205: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._205(f,arguments.length,x0) }),
      _206: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _207: (x0,x1) => x0.postMessage(x1),
      _208: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _209: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._209(f,arguments.length,x0) }),
      _210: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _211: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _212: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._212(f,arguments.length,x0) }),
      _213: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _214: (x0,x1) => x0.postMessage(x1),
      _215: x0 => globalThis.serviceWorkerListener_ = x0,
      _216: () => globalThis.serviceWorkerListener_,
      _217: x0 => globalThis.serviceErrorListener_ = x0,
      _218: () => globalThis.serviceErrorListener_,
      _235: o => Object.keys(o),
      _236: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _237: (handle) => clearTimeout(handle),
      _240: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _243: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _246: (x0,x1) => x0.send(x1),
      _252: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._252(f,arguments.length,x0) }),
      _253: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _254: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _260: () => new XMLHttpRequest(),
      _261: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _262: x0 => x0.abort(),
      _263: x0 => x0.getAllResponseHeaders(),
      _387: x0 => x0.runtime,
      _391: () => globalThis.chrome,
      _393: () => globalThis.browser,
      _435: x0 => x0.id,
      _467: (x0,x1,x2) => x0.close(x1,x2),
      _472: () => globalThis.window,
      _483: (x0,x1) => x0.fetch(x1),
      _549: x0 => x0.text(),
      _564: (x0,x1) => x0.type = x1,
      _582: x0 => x0.data,
      _583: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _584: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _586: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._586(f,arguments.length,x0) }),
      _604: (x0,x1) => new WebSocket(x0,x1),
      _605: x0 => x0.readyState,
      _607: (x0,x1) => x0.send(x1),
      _649: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _650: (x0,x1) => x0.exec(x1),
      _651: (x0,x1) => x0.test(x1),
      _652: (x0,x1) => x0.exec(x1),
      _656: o => o === undefined,
      _675: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _677: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _678: o => o instanceof RegExp,
      _679: (l, r) => l === r,
      _680: o => o,
      _681: o => o,
      _682: o => o,
      _683: b => !!b,
      _684: o => o.length,
      _687: (o, i) => o[i],
      _688: f => f.dartFunction,
      _689: l => arrayFromDartList(Int8Array, l),
      _690: l => arrayFromDartList(Uint8Array, l),
      _691: l => arrayFromDartList(Uint8ClampedArray, l),
      _692: l => arrayFromDartList(Int16Array, l),
      _693: l => arrayFromDartList(Uint16Array, l),
      _694: l => arrayFromDartList(Int32Array, l),
      _695: l => arrayFromDartList(Uint32Array, l),
      _696: l => arrayFromDartList(Float32Array, l),
      _697: l => arrayFromDartList(Float64Array, l),
      _698: x0 => new ArrayBuffer(x0),
      _699: (data, length) => {
        const getValue = dartInstance.exports.$byteDataGetUint8;
        const view = new DataView(new ArrayBuffer(length));
        for (let i = 0; i < length; i++) {
          view.setUint8(i, getValue(data, i));
        }
        return view;
      },
      _700: l => arrayFromDartList(Array, l),
      _701: () => ({}),
      _702: () => [],
      _703: l => new Array(l),
      _707: (o, p) => o[p],
      _708: (o, p, v) => o[p] = v,
      _709: (o, m, a) => o[m].apply(o, a),
      _711: o => String(o),
      _712: (p, s, f) => p.then(s, f),
      _713: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        return 17;
      },
      _714: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _715: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _716: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _718: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _720: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _722: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _727: x0 => x0.index,
      _732: x0 => x0.flags,
      _733: x0 => x0.multiline,
      _734: x0 => x0.ignoreCase,
      _735: x0 => x0.unicode,
      _736: x0 => x0.dotAll,
      _737: (x0,x1) => x0.lastIndex = x1,
      _742: x0 => x0.random(),
      _743: x0 => x0.random(),
      _744: (x0,x1) => x0.getRandomValues(x1),
      _745: () => globalThis.crypto,
      _747: () => globalThis.Math,
      _749: Function.prototype.call.bind(Number.prototype.toString),
      _805: (x0,x1) => x0.withCredentials = x1,
      _807: x0 => x0.responseURL,
      _808: x0 => x0.status,
      _809: x0 => x0.statusText,
      _811: (x0,x1) => x0.responseType = x1,
      _812: x0 => x0.response,

    };

    const baseImports = {
      dart2wasm: dart2wasm,


      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
    };

    const deferredLibraryHelper = {
      "loadModule": async (moduleName) => {
        if (!loadDeferredWasm) {
          throw "No implementation of loadDeferredWasm provided.";
        }
        const source = await Promise.resolve(loadDeferredWasm(moduleName));
        const module = await ((source instanceof Response)
            ? WebAssembly.compileStreaming(source, this.builtins)
            : WebAssembly.compile(source, this.builtins));
        return await WebAssembly.instantiate(module, {
          ...baseImports,
          ...additionalImports,
          "wasm:js-string": jsStringPolyfill,
          "module0": dartInstance.exports,
        });
      },
    };

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      "deferredLibraryHelper": deferredLibraryHelper,
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}

