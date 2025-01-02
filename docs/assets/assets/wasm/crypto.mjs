// Returns whether the `js-string` built-in is supported.
function detectJsStringBuiltins() {
  let bytes = [
    0,   97,  115, 109, 1,   0,   0,  0,   1,   4,   1,   96,  0,
    0,   2,   23,  1,   14,  119, 97, 115, 109, 58,  106, 115, 45,
    115, 116, 114, 105, 110, 103, 4,  99,  97,  115, 116, 0,   0
  ];
  return WebAssembly.validate(
    new Uint8Array(bytes), {builtins: ['js-string']});
}

// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = detectJsStringBuiltins()
      ? {builtins: ['js-string']} : {};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = detectJsStringBuiltins()
      ? {builtins: ['js-string']} : {};
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

      _13: x0 => x0.length,
      _15: (x0,x1) => x0[x1],
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
      _103: s => JSON.stringify(s),
      _104: s => printToConsole(s),
      _105: a => a.join(''),
      _106: (o, a, b) => o.replace(a, b),
      _108: (s, t) => s.split(t),
      _109: s => s.toLowerCase(),
      _110: s => s.toUpperCase(),
      _111: s => s.trim(),
      _114: (s, n) => s.repeat(n),
      _115: (s, p, i) => s.indexOf(p, i),
      _116: (s, p, i) => s.lastIndexOf(p, i),
      _117: (s) => s.replace(/\$/g, "$$$$"),
      _118: Object.is,
      _119: s => s.toUpperCase(),
      _120: s => s.toLowerCase(),
      _121: (a, i) => a.push(i),
      _129: (a, s, e) => a.slice(s, e),
      _132: a => a.length,
      _134: (a, i) => a[i],
      _135: (a, i, v) => a[i] = v,
      _137: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _138: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _139: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _140: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _141: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _142: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _143: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _144: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _147: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _148: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _150: l => new DataView(new ArrayBuffer(l)),
      _151: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _153: o => o.buffer,
      _154: o => o.byteOffset,
      _155: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _156: (b, o) => new DataView(b, o),
      _157: (b, o, l) => new DataView(b, o, l),
      _158: Function.prototype.call.bind(DataView.prototype.getUint8),
      _159: Function.prototype.call.bind(DataView.prototype.setUint8),
      _160: Function.prototype.call.bind(DataView.prototype.getInt8),
      _161: Function.prototype.call.bind(DataView.prototype.setInt8),
      _162: Function.prototype.call.bind(DataView.prototype.getUint16),
      _163: Function.prototype.call.bind(DataView.prototype.setUint16),
      _164: Function.prototype.call.bind(DataView.prototype.getInt16),
      _165: Function.prototype.call.bind(DataView.prototype.setInt16),
      _166: Function.prototype.call.bind(DataView.prototype.getUint32),
      _167: Function.prototype.call.bind(DataView.prototype.setUint32),
      _168: Function.prototype.call.bind(DataView.prototype.getInt32),
      _169: Function.prototype.call.bind(DataView.prototype.setInt32),
      _174: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _176: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _179: () => ({}),
      _194: x0 => globalThis.postMessage(x0),
      _195: x0 => globalThis.postMessage(x0),
      _196: x0 => globalThis.mrtJsHandler = x0,
      _197: x0 => globalThis.mrtWalletActivation = x0,
      _198: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._198(f,arguments.length,x0) }),
      _199: f => finalizeWrapper(f, function() { return dartInstance.exports._199(f,arguments.length) }),
      _201: (x0,x1) => new Worker(x0,x1),
      _202: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._202(f,arguments.length,x0) }),
      _203: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _204: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._204(f,arguments.length,x0) }),
      _205: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _206: (x0,x1) => x0.postMessage(x1),
      _207: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _208: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._208(f,arguments.length,x0) }),
      _209: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _210: (x0,x1) => x0.postMessage(x1),
      _211: x0 => globalThis.workerListener_ = x0,
      _212: () => globalThis.workerListener_,
      _213: x0 => globalThis.errorListener_ = x0,
      _214: () => globalThis.errorListener_,
      _231: o => Object.keys(o),
      _232: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _233: (handle) => clearTimeout(handle),
      _236: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _239: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _242: (x0,x1) => x0.send(x1),
      _248: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._248(f,arguments.length,x0) }),
      _249: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _250: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _256: () => new XMLHttpRequest(),
      _257: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _258: x0 => x0.abort(),
      _259: x0 => x0.getAllResponseHeaders(),
      _380: x0 => x0.runtime,
      _384: () => globalThis.chrome,
      _386: () => globalThis.browser,
      _428: x0 => x0.id,
      _466: () => globalThis.window,
      _475: (x0,x1) => x0.fetch(x1),
      _539: x0 => x0.text(),
      _550: (x0,x1) => x0.type = x1,
      _567: x0 => x0.data,
      _637: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _638: (x0,x1) => x0.exec(x1),
      _639: (x0,x1) => x0.test(x1),
      _640: (x0,x1) => x0.exec(x1),
      _644: o => o === undefined,
      _663: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _665: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _666: o => o instanceof RegExp,
      _667: (l, r) => l === r,
      _668: o => o,
      _669: o => o,
      _670: o => o,
      _671: b => !!b,
      _672: o => o.length,
      _675: (o, i) => o[i],
      _676: f => f.dartFunction,
      _677: l => arrayFromDartList(Int8Array, l),
      _678: l => arrayFromDartList(Uint8Array, l),
      _679: l => arrayFromDartList(Uint8ClampedArray, l),
      _680: l => arrayFromDartList(Int16Array, l),
      _681: l => arrayFromDartList(Uint16Array, l),
      _682: l => arrayFromDartList(Int32Array, l),
      _683: l => arrayFromDartList(Uint32Array, l),
      _684: l => arrayFromDartList(Float32Array, l),
      _685: l => arrayFromDartList(Float64Array, l),
      _686: x0 => new ArrayBuffer(x0),
      _687: (data, length) => {
        const getValue = dartInstance.exports.$byteDataGetUint8;
        const view = new DataView(new ArrayBuffer(length));
        for (let i = 0; i < length; i++) {
          view.setUint8(i, getValue(data, i));
        }
        return view;
      },
      _688: l => arrayFromDartList(Array, l),
      _689: (s, length) => {
        if (length == 0) return '';
      
        const read = dartInstance.exports.$stringRead1;
        let result = '';
        let index = 0;
        const chunkLength = Math.min(length - index, 500);
        let array = new Array(chunkLength);
        while (index < length) {
          const newChunkLength = Math.min(length - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(s, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      _690: (s, length) => {
        if (length == 0) return '';
      
        const read = dartInstance.exports.$stringRead2;
        let result = '';
        let index = 0;
        const chunkLength = Math.min(length - index, 500);
        let array = new Array(chunkLength);
        while (index < length) {
          const newChunkLength = Math.min(length - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(s, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      _691: (s) => {
        let length = s.length;
        let range = 0;
        for (let i = 0; i < length; i++) {
          range |= s.codePointAt(i);
        }
        const exports = dartInstance.exports;
        if (range < 256) {
          if (length <= 10) {
            if (length == 1) {
              return exports.$stringAllocate1_1(s.codePointAt(0));
            }
            if (length == 2) {
              return exports.$stringAllocate1_2(s.codePointAt(0), s.codePointAt(1));
            }
            if (length == 3) {
              return exports.$stringAllocate1_3(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2));
            }
            if (length == 4) {
              return exports.$stringAllocate1_4(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3));
            }
            if (length == 5) {
              return exports.$stringAllocate1_5(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4));
            }
            if (length == 6) {
              return exports.$stringAllocate1_6(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5));
            }
            if (length == 7) {
              return exports.$stringAllocate1_7(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6));
            }
            if (length == 8) {
              return exports.$stringAllocate1_8(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7));
            }
            if (length == 9) {
              return exports.$stringAllocate1_9(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7), s.codePointAt(8));
            }
            if (length == 10) {
              return exports.$stringAllocate1_10(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7), s.codePointAt(8), s.codePointAt(9));
            }
          }
          const dartString = exports.$stringAllocate1(length);
          const write = exports.$stringWrite1;
          for (let i = 0; i < length; i++) {
            write(dartString, i, s.codePointAt(i));
          }
          return dartString;
        } else {
          const dartString = exports.$stringAllocate2(length);
          const write = exports.$stringWrite2;
          for (let i = 0; i < length; i++) {
            write(dartString, i, s.charCodeAt(i));
          }
          return dartString;
        }
      },
      _692: () => ({}),
      _693: () => [],
      _694: l => new Array(l),
      _698: (o, p) => o[p],
      _699: (o, p, v) => o[p] = v,
      _700: (o, m, a) => o[m].apply(o, a),
      _702: o => String(o),
      _703: (p, s, f) => p.then(s, f),
      _704: o => {
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
      _705: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _706: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _707: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _709: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _711: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _713: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _718: x0 => x0.index,
      _724: x0 => x0.flags,
      _725: x0 => x0.multiline,
      _726: x0 => x0.ignoreCase,
      _727: x0 => x0.unicode,
      _728: x0 => x0.dotAll,
      _729: (x0,x1) => x0.lastIndex = x1,
      _734: v => v.toString(),
      _739: x0 => x0.random(),
      _740: x0 => x0.random(),
      _741: (x0,x1) => x0.getRandomValues(x1),
      _742: () => globalThis.crypto,
      _744: () => globalThis.Math,
      _797: (x0,x1) => x0.withCredentials = x1,
      _799: x0 => x0.responseURL,
      _800: x0 => x0.status,
      _801: x0 => x0.statusText,
      _803: (x0,x1) => x0.responseType = x1,
      _804: x0 => x0.response,

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

