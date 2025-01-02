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

      _1: (x0,x1,x2) => x0.set(x1,x2),
      _2: (x0,x1,x2) => x0.set(x1,x2),
      _3: (x0,x1) => x0.transferFromImageBitmap(x1),
      _4: x0 => x0.arrayBuffer(),
      _5: (x0,x1) => x0.transferFromImageBitmap(x1),
      _6: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._6(f,arguments.length,x0) }),
      _7: x0 => new window.FinalizationRegistry(x0),
      _8: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _9: (x0,x1) => x0.unregister(x1),
      _10: (x0,x1,x2) => x0.slice(x1,x2),
      _11: (x0,x1) => x0.decode(x1),
      _12: (x0,x1) => x0.segment(x1),
      _13: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _192: x0 => x0.select(),
      _193: (x0,x1) => x0.append(x1),
      _194: x0 => x0.remove(),
      _197: x0 => x0.unlock(),
      _202: x0 => x0.getReader(),
      _211: x0 => new MutationObserver(x0),
      _220: (x0,x1) => new OffscreenCanvas(x0,x1),
      _222: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _223: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _226: x0 => new ResizeObserver(x0),
      _229: (x0,x1) => new Intl.Segmenter(x0,x1),
      _230: x0 => x0.next(),
      _231: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _308: x0 => x0.close(),
      _309: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _310: x0 => new window.ImageDecoder(x0),
      _311: x0 => x0.close(),
      _312: x0 => ({frameIndex: x0}),
      _313: (x0,x1) => x0.decode(x1),
      _316: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._316(f,arguments.length,x0) }),
      _317: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._317(f,arguments.length,x0) }),
      _318: (x0,x1) => ({addView: x0,removeView: x1}),
      _319: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._319(f,arguments.length,x0) }),
      _320: f => finalizeWrapper(f, function() { return dartInstance.exports._320(f,arguments.length) }),
      _321: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _322: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._322(f,arguments.length,x0) }),
      _323: x0 => ({runApp: x0}),
      _324: x0 => new Uint8Array(x0),
      _326: x0 => x0.preventDefault(),
      _327: x0 => x0.stopPropagation(),
      _328: (x0,x1) => x0.addListener(x1),
      _329: (x0,x1) => x0.removeListener(x1),
      _330: (x0,x1) => x0.prepend(x1),
      _331: x0 => x0.remove(),
      _332: x0 => x0.disconnect(),
      _333: (x0,x1) => x0.addListener(x1),
      _334: (x0,x1) => x0.removeListener(x1),
      _336: (x0,x1) => x0.append(x1),
      _337: x0 => x0.remove(),
      _338: x0 => x0.stopPropagation(),
      _342: x0 => x0.preventDefault(),
      _343: (x0,x1) => x0.append(x1),
      _344: x0 => x0.remove(),
      _345: x0 => x0.preventDefault(),
      _350: (x0,x1) => x0.removeChild(x1),
      _351: (x0,x1) => x0.appendChild(x1),
      _352: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _353: (x0,x1) => x0.appendChild(x1),
      _354: (x0,x1) => x0.transferFromImageBitmap(x1),
      _355: (x0,x1) => x0.appendChild(x1),
      _356: (x0,x1) => x0.append(x1),
      _357: (x0,x1) => x0.append(x1),
      _358: (x0,x1) => x0.append(x1),
      _359: x0 => x0.remove(),
      _360: x0 => x0.remove(),
      _361: x0 => x0.remove(),
      _362: (x0,x1) => x0.appendChild(x1),
      _363: (x0,x1) => x0.appendChild(x1),
      _364: x0 => x0.remove(),
      _365: (x0,x1) => x0.append(x1),
      _366: (x0,x1) => x0.append(x1),
      _367: x0 => x0.remove(),
      _368: (x0,x1) => x0.append(x1),
      _369: (x0,x1) => x0.append(x1),
      _370: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _371: (x0,x1) => x0.append(x1),
      _372: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _373: x0 => x0.remove(),
      _374: x0 => x0.remove(),
      _375: (x0,x1) => x0.append(x1),
      _376: x0 => x0.remove(),
      _377: (x0,x1) => x0.append(x1),
      _378: x0 => x0.remove(),
      _379: x0 => x0.remove(),
      _380: x0 => x0.getBoundingClientRect(),
      _381: x0 => x0.remove(),
      _394: (x0,x1) => x0.append(x1),
      _395: x0 => x0.remove(),
      _396: (x0,x1) => x0.append(x1),
      _397: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _398: x0 => x0.preventDefault(),
      _399: x0 => x0.preventDefault(),
      _400: x0 => x0.preventDefault(),
      _401: x0 => x0.preventDefault(),
      _402: x0 => x0.remove(),
      _403: (x0,x1) => x0.observe(x1),
      _404: x0 => x0.disconnect(),
      _405: (x0,x1) => x0.appendChild(x1),
      _406: (x0,x1) => x0.appendChild(x1),
      _407: (x0,x1) => x0.appendChild(x1),
      _408: (x0,x1) => x0.append(x1),
      _409: x0 => x0.remove(),
      _410: (x0,x1) => x0.append(x1),
      _411: (x0,x1) => x0.append(x1),
      _412: (x0,x1) => x0.appendChild(x1),
      _413: (x0,x1) => x0.append(x1),
      _414: x0 => x0.remove(),
      _415: (x0,x1) => x0.append(x1),
      _419: (x0,x1) => x0.appendChild(x1),
      _420: x0 => x0.remove(),
      _976: () => globalThis.window.flutterConfiguration,
      _977: x0 => x0.assetBase,
      _982: x0 => x0.debugShowSemanticsNodes,
      _983: x0 => x0.hostElement,
      _984: x0 => x0.multiViewEnabled,
      _985: x0 => x0.nonce,
      _987: x0 => x0.fontFallbackBaseUrl,
      _988: x0 => x0.useColorEmoji,
      _992: x0 => x0.console,
      _993: x0 => x0.devicePixelRatio,
      _994: x0 => x0.document,
      _995: x0 => x0.history,
      _996: x0 => x0.innerHeight,
      _997: x0 => x0.innerWidth,
      _998: x0 => x0.location,
      _999: x0 => x0.navigator,
      _1000: x0 => x0.visualViewport,
      _1001: x0 => x0.performance,
      _1004: (x0,x1) => x0.dispatchEvent(x1),
      _1005: (x0,x1) => x0.matchMedia(x1),
      _1007: (x0,x1) => x0.getComputedStyle(x1),
      _1008: x0 => x0.screen,
      _1009: (x0,x1) => x0.requestAnimationFrame(x1),
      _1010: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1010(f,arguments.length,x0) }),
      _1014: (x0,x1) => x0.warn(x1),
      _1016: (x0,x1) => x0.debug(x1),
      _1017: () => globalThis.window,
      _1018: () => globalThis.Intl,
      _1019: () => globalThis.Symbol,
      _1022: x0 => x0.clipboard,
      _1023: x0 => x0.maxTouchPoints,
      _1024: x0 => x0.vendor,
      _1025: x0 => x0.language,
      _1026: x0 => x0.platform,
      _1027: x0 => x0.userAgent,
      _1028: x0 => x0.languages,
      _1029: x0 => x0.documentElement,
      _1030: (x0,x1) => x0.querySelector(x1),
      _1034: (x0,x1) => x0.createElement(x1),
      _1035: (x0,x1) => x0.execCommand(x1),
      _1039: (x0,x1) => x0.createTextNode(x1),
      _1040: (x0,x1) => x0.createEvent(x1),
      _1044: x0 => x0.head,
      _1045: x0 => x0.body,
      _1046: (x0,x1) => x0.title = x1,
      _1049: x0 => x0.activeElement,
      _1052: x0 => x0.visibilityState,
      _1053: x0 => x0.hasFocus(),
      _1054: () => globalThis.document,
      _1055: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1057: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1060: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1060(f,arguments.length,x0) }),
      _1061: x0 => x0.target,
      _1063: x0 => x0.timeStamp,
      _1064: x0 => x0.type,
      _1066: x0 => x0.preventDefault(),
      _1068: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _1075: x0 => x0.firstChild,
      _1080: x0 => x0.parentElement,
      _1082: x0 => x0.parentNode,
      _1085: (x0,x1) => x0.removeChild(x1),
      _1086: (x0,x1) => x0.removeChild(x1),
      _1087: x0 => x0.isConnected,
      _1088: (x0,x1) => x0.textContent = x1,
      _1090: (x0,x1) => x0.contains(x1),
      _1095: x0 => x0.firstElementChild,
      _1097: x0 => x0.nextElementSibling,
      _1098: x0 => x0.clientHeight,
      _1099: x0 => x0.clientWidth,
      _1100: x0 => x0.offsetHeight,
      _1101: x0 => x0.offsetWidth,
      _1102: x0 => x0.id,
      _1103: (x0,x1) => x0.id = x1,
      _1106: (x0,x1) => x0.spellcheck = x1,
      _1107: x0 => x0.tagName,
      _1108: x0 => x0.style,
      _1109: (x0,x1) => x0.append(x1),
      _1110: (x0,x1) => x0.getAttribute(x1),
      _1111: x0 => x0.getBoundingClientRect(),
      _1116: (x0,x1) => x0.closest(x1),
      _1119: (x0,x1) => x0.querySelectorAll(x1),
      _1121: x0 => x0.remove(),
      _1122: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1123: (x0,x1) => x0.removeAttribute(x1),
      _1124: (x0,x1) => x0.tabIndex = x1,
      _1126: (x0,x1) => x0.focus(x1),
      _1127: x0 => x0.scrollTop,
      _1128: (x0,x1) => x0.scrollTop = x1,
      _1129: x0 => x0.scrollLeft,
      _1130: (x0,x1) => x0.scrollLeft = x1,
      _1131: x0 => x0.classList,
      _1132: (x0,x1) => x0.className = x1,
      _1139: (x0,x1) => x0.getElementsByClassName(x1),
      _1141: x0 => x0.click(),
      _1143: (x0,x1) => x0.hasAttribute(x1),
      _1146: (x0,x1) => x0.attachShadow(x1),
      _1151: (x0,x1) => x0.getPropertyValue(x1),
      _1153: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _1155: (x0,x1) => x0.removeProperty(x1),
      _1157: x0 => x0.offsetLeft,
      _1158: x0 => x0.offsetTop,
      _1159: x0 => x0.offsetParent,
      _1161: (x0,x1) => x0.name = x1,
      _1162: x0 => x0.content,
      _1163: (x0,x1) => x0.content = x1,
      _1177: (x0,x1) => x0.nonce = x1,
      _1183: x0 => x0.now(),
      _1185: (x0,x1) => x0.width = x1,
      _1187: (x0,x1) => x0.height = x1,
      _1191: (x0,x1) => x0.getContext(x1),
      _1263: x0 => x0.width,
      _1264: x0 => x0.height,
      _1267: (x0,x1) => x0.fetch(x1),
      _1268: x0 => x0.status,
      _1270: x0 => x0.body,
      _1271: x0 => x0.arrayBuffer(),
      _1277: x0 => x0.read(),
      _1278: x0 => x0.value,
      _1279: x0 => x0.done,
      _1281: x0 => x0.name,
      _1282: x0 => x0.x,
      _1283: x0 => x0.y,
      _1286: x0 => x0.top,
      _1287: x0 => x0.right,
      _1288: x0 => x0.bottom,
      _1289: x0 => x0.left,
      _1299: x0 => x0.height,
      _1300: x0 => x0.width,
      _1301: (x0,x1) => x0.value = x1,
      _1303: (x0,x1) => x0.placeholder = x1,
      _1304: (x0,x1) => x0.name = x1,
      _1305: x0 => x0.selectionDirection,
      _1306: x0 => x0.selectionStart,
      _1307: x0 => x0.selectionEnd,
      _1310: x0 => x0.value,
      _1312: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1315: x0 => x0.readText(),
      _1316: (x0,x1) => x0.writeText(x1),
      _1317: x0 => x0.altKey,
      _1318: x0 => x0.code,
      _1319: x0 => x0.ctrlKey,
      _1320: x0 => x0.key,
      _1321: x0 => x0.keyCode,
      _1322: x0 => x0.location,
      _1323: x0 => x0.metaKey,
      _1324: x0 => x0.repeat,
      _1325: x0 => x0.shiftKey,
      _1326: x0 => x0.isComposing,
      _1327: (x0,x1) => x0.getModifierState(x1),
      _1329: x0 => x0.state,
      _1330: (x0,x1) => x0.go(x1),
      _1333: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1334: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1335: x0 => x0.pathname,
      _1336: x0 => x0.search,
      _1337: x0 => x0.hash,
      _1341: x0 => x0.state,
      _1347: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1347(f,arguments.length,x0,x1) }),
      _1350: (x0,x1,x2) => x0.observe(x1,x2),
      _1353: x0 => x0.attributeName,
      _1354: x0 => x0.type,
      _1355: x0 => x0.matches,
      _1358: x0 => x0.matches,
      _1360: x0 => x0.relatedTarget,
      _1361: x0 => x0.clientX,
      _1362: x0 => x0.clientY,
      _1363: x0 => x0.offsetX,
      _1364: x0 => x0.offsetY,
      _1367: x0 => x0.button,
      _1368: x0 => x0.buttons,
      _1369: x0 => x0.ctrlKey,
      _1370: (x0,x1) => x0.getModifierState(x1),
      _1373: x0 => x0.pointerId,
      _1374: x0 => x0.pointerType,
      _1375: x0 => x0.pressure,
      _1376: x0 => x0.tiltX,
      _1377: x0 => x0.tiltY,
      _1378: x0 => x0.getCoalescedEvents(),
      _1380: x0 => x0.deltaX,
      _1381: x0 => x0.deltaY,
      _1382: x0 => x0.wheelDeltaX,
      _1383: x0 => x0.wheelDeltaY,
      _1384: x0 => x0.deltaMode,
      _1390: x0 => x0.changedTouches,
      _1392: x0 => x0.clientX,
      _1393: x0 => x0.clientY,
      _1395: x0 => x0.data,
      _1398: (x0,x1) => x0.disabled = x1,
      _1399: (x0,x1) => x0.type = x1,
      _1400: (x0,x1) => x0.max = x1,
      _1401: (x0,x1) => x0.min = x1,
      _1402: (x0,x1) => x0.value = x1,
      _1403: x0 => x0.value,
      _1404: x0 => x0.disabled,
      _1405: (x0,x1) => x0.disabled = x1,
      _1406: (x0,x1) => x0.placeholder = x1,
      _1407: (x0,x1) => x0.name = x1,
      _1408: (x0,x1) => x0.autocomplete = x1,
      _1409: x0 => x0.selectionDirection,
      _1410: x0 => x0.selectionStart,
      _1411: x0 => x0.selectionEnd,
      _1415: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1420: (x0,x1) => x0.add(x1),
      _1423: (x0,x1) => x0.noValidate = x1,
      _1424: (x0,x1) => x0.method = x1,
      _1425: (x0,x1) => x0.action = x1,
      _1431: (x0,x1) => x0.getContext(x1),
      _1433: x0 => x0.convertToBlob(),
      _1450: x0 => x0.orientation,
      _1451: x0 => x0.width,
      _1452: x0 => x0.height,
      _1453: (x0,x1) => x0.lock(x1),
      _1471: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1471(f,arguments.length,x0,x1) }),
      _1482: x0 => x0.length,
      _1483: (x0,x1) => x0.item(x1),
      _1484: x0 => x0.length,
      _1485: (x0,x1) => x0.item(x1),
      _1486: x0 => x0.iterator,
      _1487: x0 => x0.Segmenter,
      _1488: x0 => x0.v8BreakIterator,
      _1492: x0 => x0.done,
      _1493: x0 => x0.value,
      _1494: x0 => x0.index,
      _1498: (x0,x1) => x0.adoptText(x1),
      _1499: x0 => x0.first(),
      _1500: x0 => x0.next(),
      _1501: x0 => x0.current(),
      _1512: x0 => x0.hostElement,
      _1513: x0 => x0.viewConstraints,
      _1515: x0 => x0.maxHeight,
      _1516: x0 => x0.maxWidth,
      _1517: x0 => x0.minHeight,
      _1518: x0 => x0.minWidth,
      _1519: x0 => x0.loader,
      _1520: () => globalThis._flutter,
      _1521: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1522: (x0,x1,x2) => x0.call(x1,x2),
      _1523: () => globalThis.Promise,
      _1524: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1524(f,arguments.length,x0,x1) }),
      _1527: x0 => x0.length,
      _1530: x0 => x0.tracks,
      _1534: x0 => x0.image,
      _1539: x0 => x0.codedWidth,
      _1540: x0 => x0.codedHeight,
      _1543: x0 => x0.duration,
      _1547: x0 => x0.ready,
      _1548: x0 => x0.selectedTrack,
      _1549: x0 => x0.repetitionCount,
      _1550: x0 => x0.frameCount,
      _1595: (x0,x1,x2) => x0.call(x1,x2),
      _1596: (x0,x1) => x0.postMessage(x1),
      _1597: (x0,x1) => x0.postMessage(x1),
      _1598: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1598(f,arguments.length,x0) }),
      _1599: (x0,x1) => x0.addListener(x1),
      _1600: (x0,x1) => x0.postMessage(x1),
      _1601: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1601(f,arguments.length,x0) }),
      _1602: (x0,x1) => x0.removeListener(x1),
      _1603: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1603(f,arguments.length,x0,x1) }),
      _1604: (x0,x1) => x0.addListener(x1),
      _1605: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1605(f,arguments.length,x0) }),
      _1606: (x0,x1) => x0.addListener(x1),
      _1607: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1607(f,arguments.length,x0,x1,x2) }),
      _1608: (x0,x1) => x0.addListener(x1),
      _1609: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1609(f,arguments.length,x0) }),
      _1610: (x0,x1) => x0.addListener(x1),
      _1611: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1611(f,arguments.length,x0) }),
      _1612: (x0,x1) => x0.addListener(x1),
      _1630: x0 => new BarcodeDetector(x0),
      _1658: x0 => new Array(x0),
      _1660: x0 => x0.length,
      _1662: (x0,x1) => x0[x1],
      _1663: (x0,x1,x2) => x0[x1] = x2,
      _1666: (x0,x1,x2) => new DataView(x0,x1,x2),
      _1668: x0 => new Int8Array(x0),
      _1669: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _1670: x0 => new Uint8Array(x0),
      _1676: x0 => new Uint16Array(x0),
      _1678: x0 => new Int32Array(x0),
      _1680: x0 => new Uint32Array(x0),
      _1682: x0 => new Float32Array(x0),
      _1684: x0 => new Float64Array(x0),
      _1690: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1690(f,arguments.length,x0) }),
      _1691: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1691(f,arguments.length,x0) }),
      _1716: (decoder, codeUnits) => decoder.decode(codeUnits),
      _1717: () => new TextDecoder("utf-8", {fatal: true}),
      _1718: () => new TextDecoder("utf-8", {fatal: false}),
      _1719: x0 => new WeakRef(x0),
      _1720: x0 => x0.deref(),
      _1726: Date.now,
      _1728: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1729: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1730: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1731: () => typeof dartUseDateNowForTicks !== "undefined",
      _1732: () => 1000 * performance.now(),
      _1733: () => Date.now(),
      _1734: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1735: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1736: () => new WeakMap(),
      _1737: (map, o) => map.get(o),
      _1738: (map, o, v) => map.set(o, v),
      _1739: () => globalThis.WeakRef,
      _1749: s => JSON.stringify(s),
      _1750: s => printToConsole(s),
      _1751: a => a.join(''),
      _1752: (o, a, b) => o.replace(a, b),
      _1754: (s, t) => s.split(t),
      _1755: s => s.toLowerCase(),
      _1756: s => s.toUpperCase(),
      _1757: s => s.trim(),
      _1758: s => s.trimLeft(),
      _1759: s => s.trimRight(),
      _1760: (s, n) => s.repeat(n),
      _1761: (s, p, i) => s.indexOf(p, i),
      _1762: (s, p, i) => s.lastIndexOf(p, i),
      _1763: (s) => s.replace(/\$/g, "$$$$"),
      _1764: Object.is,
      _1765: s => s.toUpperCase(),
      _1766: s => s.toLowerCase(),
      _1767: (a, i) => a.push(i),
      _1768: (a, i) => a.splice(i, 1)[0],
      _1770: (a, l) => a.length = l,
      _1771: a => a.pop(),
      _1772: (a, i) => a.splice(i, 1),
      _1774: (a, s) => a.join(s),
      _1775: (a, s, e) => a.slice(s, e),
      _1777: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1778: a => a.length,
      _1780: (a, i) => a[i],
      _1781: (a, i, v) => a[i] = v,
      _1783: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1784: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1785: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1786: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1787: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1788: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1789: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1790: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1792: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1793: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1794: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1795: (t, s) => t.set(s),
      _1796: l => new DataView(new ArrayBuffer(l)),
      _1797: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1799: o => o.buffer,
      _1800: o => o.byteOffset,
      _1801: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1802: (b, o) => new DataView(b, o),
      _1803: (b, o, l) => new DataView(b, o, l),
      _1804: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1805: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1806: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1807: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1808: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1809: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1810: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1811: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1812: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1813: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1814: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1815: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1818: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1819: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1820: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1821: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1822: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1823: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1824: x0 => x0.terminate(),
      _1825: () => ({}),
      _1826: (x0,x1) => new Worker(x0,x1),
      _1827: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1827(f,arguments.length,x0) }),
      _1828: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1829: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1829(f,arguments.length,x0) }),
      _1830: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1831: (x0,x1) => x0.postMessage(x1),
      _1832: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1833: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1833(f,arguments.length,x0) }),
      _1834: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1835: (x0,x1) => x0.postMessage(x1),
      _1836: x0 => globalThis.workerListener_ = x0,
      _1837: () => globalThis.workerListener_,
      _1838: x0 => globalThis.errorListener_ = x0,
      _1839: () => globalThis.errorListener_,
      _1841: (x0,x1) => new Worker(x0,x1),
      _1842: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1842(f,arguments.length,x0) }),
      _1843: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1844: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1844(f,arguments.length,x0) }),
      _1845: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1846: (x0,x1) => x0.postMessage(x1),
      _1847: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1848: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1848(f,arguments.length,x0) }),
      _1849: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1850: (x0,x1) => x0.postMessage(x1),
      _1851: x0 => globalThis.workerListener_ = x0,
      _1852: () => globalThis.workerListener_,
      _1853: x0 => globalThis.errorListener_ = x0,
      _1854: () => globalThis.errorListener_,
      _1867: (o, t) => o instanceof t,
      _1869: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1869(f,arguments.length,x0) }),
      _1870: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1870(f,arguments.length,x0) }),
      _1871: o => Object.keys(o),
      _1872: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1873: (handle) => clearTimeout(handle),
      _1874: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1875: (handle) => clearInterval(handle),
      _1876: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1877: () => Date.now(),
      _1879: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1882: (x0,x1) => x0.send(x1),
      _1887: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1887(f,arguments.length,x0) }),
      _1888: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1888(f,arguments.length,x0) }),
      _1889: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1890: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1896: () => new XMLHttpRequest(),
      _1897: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1898: x0 => x0.abort(),
      _1899: x0 => x0.getAllResponseHeaders(),
      _1901: (x0,x1) => x0.get(x1),
      _1902: (x0,x1) => x0.query(x1),
      _1905: (x0,x1,x2,x3) => x0.sendMessage(x1,x2,x3),
      _1906: x0 => x0.onActivated,
      _1908: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11) => ({active: x0,audible: x1,autoDiscardable: x2,currentWindow: x3,discarded: x4,highlighted: x5,index: x6,lastFocusedWindow: x7,muted: x8,pinned: x9,windowId: x10,url: x11}),
      _1919: x0 => x0.favIconUrl,
      _1926: x0 => x0.id,
      _1933: x0 => x0.title,
      _1935: x0 => x0.url,
      _1954: x0 => x0.windowId,
      _1982: (x0,x1) => x0.getCurrent(x1),
      _1987: (x0,x1) => ({populate: x0,windowTypes: x1}),
      _2003: x0 => x0.id,
      _2014: x0 => x0.storage,
      _2015: x0 => x0.tabs,
      _2016: x0 => x0.runtime,
      _2018: x0 => x0.windows,
      _2020: x0 => x0.runtime,
      _2023: () => globalThis.chrome,
      _2024: () => globalThis.chrome,
      _2025: () => globalThis.browser,
      _2026: () => globalThis.browser,
      _2027: (x0,x1) => x0.getItem(x1),
      _2028: (x0,x1) => x0.getItem(x1),
      _2029: (x0,x1,x2) => x0.setItem(x1,x2),
      _2030: x0 => x0.clear(),
      _2031: (x0,x1,x2) => x0.setItem(x1,x2),
      _2032: (x0,x1,x2) => x0.setItem(x1,x2),
      _2034: (x0,x1) => x0.getItem(x1),
      _2035: (x0,x1) => x0.removeItem(x1),
      _2036: (x0,x1,x2) => x0.setItem(x1,x2),
      _2037: x0 => x0.arrayBuffer(),
      _2038: x0 => ({type: x0}),
      _2039: (x0,x1,x2) => new File(x0,x1,x2),
      _2040: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _2041: () => globalThis.localStorage,
      _2045: (x0,x1) => x0.removeItem(x1),
      _2048: x0 => globalThis.Object.entries(x0),
      _2049: (x0,x1,x2,x3) => ({data: x0,type: x1,additional: x2,platform: x3}),
      _2050: x0 => x0.type,
      _2051: (x0,x1) => x0.client_id = x1,
      _2052: x0 => x0.client_id,
      _2053: (x0,x1) => x0.request_id = x1,
      _2054: x0 => x0.request_id,
      _2055: x0 => x0.platform,
      _2056: x0 => x0.data,
      _2057: x0 => x0.additional,
      _2064: (x0,x1,x2,x3) => x0.sendMessage(x1,x2,x3),
      _2066: (x0,x1) => x0.getURL(x1),
      _2067: x0 => x0.id,
      _2068: x0 => x0.id,
      _2070: x0 => x0.onMessage,
      _2072: x0 => x0.onConnect,
      _2085: x0 => x0.onDisconnect,
      _2086: x0 => x0.onMessage,
      _2100: (x0,x1,x2) => x0.close(x1,x2),
      _2101: x0 => x0.close(),
      _2106: () => globalThis.window,
      _2109: x0 => x0.BarcodeDetector,
      _2110: x0 => x0.navigator,
      _2111: x0 => x0.navigator,
      _2113: x0 => x0.document,
      _2117: (x0,x1) => x0.fetch(x1),
      _2121: x0 => x0.focus(),
      _2135: (x0,x1) => x0.createElement(x1),
      _2136: x0 => x0.body,
      _2139: x0 => x0.hasFocus(),
      _2140: x0 => globalThis.URL.createObjectURL(x0),
      _2141: (x0,x1) => x0.appendChild(x1),
      _2142: x0 => x0.click(),
      _2143: (x0,x1) => x0.removeChild(x1),
      _2145: (x0,x1) => x0.writeText(x1),
      _2146: x0 => x0.readText(),
      _2149: x0 => x0.mediaDevices,
      _2150: x0 => x0.userAgent,
      _2151: (x0,x1,x2,x3,x4) => x0.share(x1,x2,x3,x4),
      _2152: x0 => x0.clipboard,
      _2154: (x0,x1) => x0.getUserMedia(x1),
      _2156: (x0,x1) => x0.detect(x1),
      _2161: x0 => x0.rawValue,
      _2176: (x0,x1) => new Blob(x0,x1),
      _2180: x0 => x0.ok,
      _2181: x0 => x0.status,
      _2182: x0 => x0.arrayBuffer(),
      _2183: x0 => x0.text(),
      _2198: (x0,x1) => x0.type = x1,
      _2216: x0 => x0.data,
      _2217: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _2218: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _2220: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2220(f,arguments.length,x0) }),
      _2238: (x0,x1) => new WebSocket(x0,x1),
      _2239: x0 => x0.readyState,
      _2241: (x0,x1) => x0.send(x1),
      _2243: x0 => x0.local,
      _2245: x0 => x0.session,
      _2252: (x0,x1) => x0.get(x1),
      _2255: (x0,x1) => x0.get(x1),
      _2258: (x0,x1) => x0.remove(x1),
      _2260: (x0,x1) => x0.remove(x1),
      _2264: (x0,x1) => x0.set(x1),
      _2283: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2284: (x0,x1) => x0.exec(x1),
      _2285: (x0,x1) => x0.test(x1),
      _2286: (x0,x1) => x0.exec(x1),
      _2287: (x0,x1) => x0.exec(x1),
      _2288: x0 => x0.pop(),
      _2290: o => o === undefined,
      _2309: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2311: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2312: o => o instanceof RegExp,
      _2313: (l, r) => l === r,
      _2314: o => o,
      _2315: o => o,
      _2316: o => o,
      _2317: b => !!b,
      _2318: o => o.length,
      _2321: (o, i) => o[i],
      _2322: f => f.dartFunction,
      _2323: l => arrayFromDartList(Int8Array, l),
      _2324: l => arrayFromDartList(Uint8Array, l),
      _2325: l => arrayFromDartList(Uint8ClampedArray, l),
      _2326: l => arrayFromDartList(Int16Array, l),
      _2327: l => arrayFromDartList(Uint16Array, l),
      _2328: l => arrayFromDartList(Int32Array, l),
      _2329: l => arrayFromDartList(Uint32Array, l),
      _2330: l => arrayFromDartList(Float32Array, l),
      _2331: l => arrayFromDartList(Float64Array, l),
      _2332: x0 => new ArrayBuffer(x0),
      _2333: (data, length) => {
        const getValue = dartInstance.exports.$byteDataGetUint8;
        const view = new DataView(new ArrayBuffer(length));
        for (let i = 0; i < length; i++) {
          view.setUint8(i, getValue(data, i));
        }
        return view;
      },
      _2334: l => arrayFromDartList(Array, l),
      _2335: (s, length) => {
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
      _2336: (s, length) => {
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
      _2337: (s) => {
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
      _2338: () => ({}),
      _2339: () => [],
      _2340: l => new Array(l),
      _2341: () => globalThis,
      _2342: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2343: (o, p) => p in o,
      _2344: (o, p) => o[p],
      _2345: (o, p, v) => o[p] = v,
      _2346: (o, m, a) => o[m].apply(o, a),
      _2348: o => String(o),
      _2349: (p, s, f) => p.then(s, f),
      _2350: o => {
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
      _2351: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2352: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2353: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2354: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2355: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2356: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2357: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2358: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2359: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2360: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2361: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2364: x0 => x0.index,
      _2368: (x0,x1) => x0.exec(x1),
      _2370: x0 => x0.flags,
      _2371: x0 => x0.multiline,
      _2372: x0 => x0.ignoreCase,
      _2373: x0 => x0.unicode,
      _2374: x0 => x0.dotAll,
      _2375: (x0,x1) => x0.lastIndex = x1,
      _2380: v => v.toString(),
      _2381: (d, digits) => d.toFixed(digits),
      _2385: x0 => x0.random(),
      _2386: x0 => x0.random(),
      _2387: (x0,x1) => x0.getRandomValues(x1),
      _2388: () => globalThis.crypto,
      _2390: () => globalThis.Math,
      _2443: (x0,x1) => x0.withCredentials = x1,
      _2445: x0 => x0.responseURL,
      _2446: x0 => x0.status,
      _2447: x0 => x0.statusText,
      _2449: (x0,x1) => x0.responseType = x1,
      _2450: x0 => x0.response,
      _14092: x0 => x0.id,
      _14093: (x0,x1) => x0.id = x1,
      _14098: (x0,x1) => x0.autoplay = x1,
      _14104: (x0,x1) => x0.href = x1,
      _14105: (x0,x1) => x0.target = x1,
      _14106: (x0,x1) => x0.download = x1,
      _14110: (x0,x1) => x0.srcObject = x1,
      _14124: x0 => x0.stop(),
      _14126: x0 => x0.getTracks(),

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

