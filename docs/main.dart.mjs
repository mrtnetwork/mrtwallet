
// `modulePromise` is a promise to the `WebAssembly.module` object to be
//   instantiated.
// `importObjectPromise` is a promise to an object that contains any additional
//   imports needed by the module that aren't provided by the standard runtime.
//   The fields on this object will be merged into the importObject with which
//   the module will be instantiated.
// This function returns a promise to the instantiated module.
export const instantiate = async (modulePromise, importObjectPromise) => {
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
_167: x0 => x0.select(),
_168: (x0,x1) => x0.append(x1),
_169: x0 => x0.remove(),
_172: x0 => x0.unlock(),
_177: x0 => x0.getReader(),
_189: x0 => new MutationObserver(x0),
_206: (x0,x1) => new OffscreenCanvas(x0,x1),
_208: (x0,x1,x2) => x0.addEventListener(x1,x2),
_209: (x0,x1,x2) => x0.removeEventListener(x1,x2),
_212: x0 => new ResizeObserver(x0),
_215: (x0,x1) => new Intl.Segmenter(x0,x1),
_216: x0 => x0.next(),
_217: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
_294: x0 => x0.close(),
_295: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
_296: x0 => new window.ImageDecoder(x0),
_297: x0 => x0.close(),
_298: x0 => ({frameIndex: x0}),
_299: (x0,x1) => x0.decode(x1),
_302: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._302(f,arguments.length,x0) }),
_303: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._303(f,arguments.length,x0) }),
_304: (x0,x1) => ({addView: x0,removeView: x1}),
_305: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._305(f,arguments.length,x0) }),
_306: f => finalizeWrapper(f, function() { return dartInstance.exports._306(f,arguments.length) }),
_307: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
_308: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._308(f,arguments.length,x0) }),
_309: x0 => ({runApp: x0}),
_310: x0 => new Uint8Array(x0),
_312: x0 => x0.preventDefault(),
_313: x0 => x0.stopPropagation(),
_314: (x0,x1) => x0.addListener(x1),
_315: (x0,x1) => x0.removeListener(x1),
_316: (x0,x1) => x0.prepend(x1),
_317: x0 => x0.remove(),
_318: x0 => x0.disconnect(),
_319: (x0,x1) => x0.addListener(x1),
_320: (x0,x1) => x0.removeListener(x1),
_322: (x0,x1) => x0.append(x1),
_323: x0 => x0.remove(),
_324: x0 => x0.stopPropagation(),
_328: x0 => x0.preventDefault(),
_329: (x0,x1) => x0.append(x1),
_330: x0 => x0.remove(),
_331: x0 => x0.preventDefault(),
_336: (x0,x1) => x0.appendChild(x1),
_337: (x0,x1,x2) => x0.insertBefore(x1,x2),
_338: (x0,x1) => x0.removeChild(x1),
_339: (x0,x1) => x0.appendChild(x1),
_340: (x0,x1) => x0.transferFromImageBitmap(x1),
_341: (x0,x1) => x0.append(x1),
_342: (x0,x1) => x0.append(x1),
_343: (x0,x1) => x0.append(x1),
_344: x0 => x0.remove(),
_345: x0 => x0.remove(),
_346: x0 => x0.remove(),
_347: (x0,x1) => x0.appendChild(x1),
_348: (x0,x1) => x0.appendChild(x1),
_349: x0 => x0.remove(),
_350: (x0,x1) => x0.append(x1),
_351: (x0,x1) => x0.append(x1),
_352: x0 => x0.remove(),
_353: (x0,x1) => x0.append(x1),
_354: (x0,x1) => x0.append(x1),
_355: (x0,x1,x2) => x0.insertBefore(x1,x2),
_356: (x0,x1) => x0.append(x1),
_357: (x0,x1,x2) => x0.insertBefore(x1,x2),
_358: x0 => x0.remove(),
_359: x0 => x0.remove(),
_360: (x0,x1) => x0.append(x1),
_361: x0 => x0.remove(),
_362: (x0,x1) => x0.append(x1),
_363: x0 => x0.remove(),
_364: x0 => x0.remove(),
_365: x0 => x0.getBoundingClientRect(),
_366: x0 => x0.remove(),
_367: x0 => x0.blur(),
_368: x0 => x0.remove(),
_369: x0 => x0.blur(),
_370: x0 => x0.remove(),
_383: (x0,x1) => x0.append(x1),
_384: x0 => x0.remove(),
_385: (x0,x1) => x0.append(x1),
_386: (x0,x1,x2) => x0.insertBefore(x1,x2),
_387: x0 => x0.preventDefault(),
_388: x0 => x0.preventDefault(),
_389: x0 => x0.preventDefault(),
_390: x0 => x0.preventDefault(),
_391: x0 => x0.remove(),
_392: (x0,x1) => x0.observe(x1),
_393: x0 => x0.disconnect(),
_394: (x0,x1) => x0.appendChild(x1),
_395: (x0,x1) => x0.appendChild(x1),
_396: (x0,x1) => x0.appendChild(x1),
_397: (x0,x1) => x0.append(x1),
_398: x0 => x0.remove(),
_399: (x0,x1) => x0.append(x1),
_400: (x0,x1) => x0.append(x1),
_401: (x0,x1) => x0.appendChild(x1),
_402: (x0,x1) => x0.append(x1),
_403: x0 => x0.remove(),
_404: (x0,x1) => x0.append(x1),
_408: (x0,x1) => x0.appendChild(x1),
_409: x0 => x0.remove(),
_969: () => globalThis.window.flutterConfiguration,
_970: x0 => x0.assetBase,
_975: x0 => x0.debugShowSemanticsNodes,
_976: x0 => x0.hostElement,
_977: x0 => x0.multiViewEnabled,
_978: x0 => x0.nonce,
_980: x0 => x0.fontFallbackBaseUrl,
_981: x0 => x0.useColorEmoji,
_985: x0 => x0.console,
_986: x0 => x0.devicePixelRatio,
_987: x0 => x0.document,
_988: x0 => x0.history,
_989: x0 => x0.innerHeight,
_990: x0 => x0.innerWidth,
_991: x0 => x0.location,
_992: x0 => x0.navigator,
_993: x0 => x0.visualViewport,
_994: x0 => x0.performance,
_995: (x0,x1) => x0.fetch(x1),
_1000: (x0,x1) => x0.dispatchEvent(x1),
_1001: (x0,x1) => x0.matchMedia(x1),
_1002: (x0,x1) => x0.getComputedStyle(x1),
_1004: x0 => x0.screen,
_1005: (x0,x1) => x0.requestAnimationFrame(x1),
_1006: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1006(f,arguments.length,x0) }),
_1010: (x0,x1) => x0.warn(x1),
_1012: (x0,x1) => x0.debug(x1),
_1013: () => globalThis.window,
_1014: () => globalThis.Intl,
_1015: () => globalThis.Symbol,
_1018: x0 => x0.clipboard,
_1019: x0 => x0.maxTouchPoints,
_1020: x0 => x0.vendor,
_1021: x0 => x0.language,
_1022: x0 => x0.platform,
_1023: x0 => x0.userAgent,
_1024: x0 => x0.languages,
_1025: x0 => x0.documentElement,
_1026: (x0,x1) => x0.querySelector(x1),
_1029: (x0,x1) => x0.createElement(x1),
_1031: (x0,x1) => x0.execCommand(x1),
_1035: (x0,x1) => x0.createTextNode(x1),
_1036: (x0,x1) => x0.createEvent(x1),
_1040: x0 => x0.head,
_1041: x0 => x0.body,
_1042: (x0,x1) => x0.title = x1,
_1045: x0 => x0.activeElement,
_1047: x0 => x0.visibilityState,
_1048: () => globalThis.document,
_1049: (x0,x1,x2) => x0.addEventListener(x1,x2),
_1050: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
_1051: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
_1052: (x0,x1,x2) => x0.removeEventListener(x1,x2),
_1055: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1055(f,arguments.length,x0) }),
_1056: x0 => x0.target,
_1058: x0 => x0.timeStamp,
_1059: x0 => x0.type,
_1061: x0 => x0.preventDefault(),
_1065: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
_1070: x0 => x0.firstChild,
_1076: x0 => x0.parentElement,
_1078: x0 => x0.parentNode,
_1081: (x0,x1) => x0.removeChild(x1),
_1082: (x0,x1) => x0.removeChild(x1),
_1083: x0 => x0.isConnected,
_1084: (x0,x1) => x0.textContent = x1,
_1087: (x0,x1) => x0.contains(x1),
_1092: x0 => x0.firstElementChild,
_1094: x0 => x0.nextElementSibling,
_1095: x0 => x0.clientHeight,
_1096: x0 => x0.clientWidth,
_1097: x0 => x0.offsetHeight,
_1098: x0 => x0.offsetWidth,
_1099: x0 => x0.id,
_1100: (x0,x1) => x0.id = x1,
_1103: (x0,x1) => x0.spellcheck = x1,
_1104: x0 => x0.tagName,
_1105: x0 => x0.style,
_1107: (x0,x1) => x0.append(x1),
_1108: (x0,x1) => x0.getAttribute(x1),
_1109: x0 => x0.getBoundingClientRect(),
_1112: (x0,x1) => x0.closest(x1),
_1114: (x0,x1) => x0.querySelectorAll(x1),
_1115: x0 => x0.remove(),
_1116: (x0,x1,x2) => x0.setAttribute(x1,x2),
_1118: (x0,x1) => x0.removeAttribute(x1),
_1119: (x0,x1) => x0.tabIndex = x1,
_1121: (x0,x1) => x0.focus(x1),
_1122: x0 => x0.scrollTop,
_1123: (x0,x1) => x0.scrollTop = x1,
_1124: x0 => x0.scrollLeft,
_1125: (x0,x1) => x0.scrollLeft = x1,
_1126: x0 => x0.classList,
_1127: (x0,x1) => x0.className = x1,
_1131: (x0,x1) => x0.getElementsByClassName(x1),
_1132: x0 => x0.click(),
_1133: (x0,x1) => x0.hasAttribute(x1),
_1136: (x0,x1) => x0.attachShadow(x1),
_1140: (x0,x1) => x0.getPropertyValue(x1),
_1142: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
_1144: (x0,x1) => x0.removeProperty(x1),
_1146: x0 => x0.offsetLeft,
_1147: x0 => x0.offsetTop,
_1148: x0 => x0.offsetParent,
_1150: (x0,x1) => x0.name = x1,
_1151: x0 => x0.content,
_1152: (x0,x1) => x0.content = x1,
_1165: (x0,x1) => x0.nonce = x1,
_1170: x0 => x0.now(),
_1172: (x0,x1) => x0.width = x1,
_1174: (x0,x1) => x0.height = x1,
_1178: (x0,x1) => x0.getContext(x1),
_1251: x0 => x0.width,
_1252: x0 => x0.height,
_1256: x0 => x0.status,
_1258: x0 => x0.body,
_1259: x0 => x0.arrayBuffer(),
_1264: x0 => x0.read(),
_1265: x0 => x0.value,
_1266: x0 => x0.done,
_1268: x0 => x0.name,
_1269: x0 => x0.x,
_1270: x0 => x0.y,
_1273: x0 => x0.top,
_1274: x0 => x0.right,
_1275: x0 => x0.bottom,
_1276: x0 => x0.left,
_1285: x0 => x0.height,
_1286: x0 => x0.width,
_1287: (x0,x1) => x0.value = x1,
_1289: (x0,x1) => x0.placeholder = x1,
_1290: (x0,x1) => x0.name = x1,
_1291: x0 => x0.selectionDirection,
_1292: x0 => x0.selectionStart,
_1293: x0 => x0.selectionEnd,
_1296: x0 => x0.value,
_1298: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
_1303: x0 => x0.readText(),
_1304: (x0,x1) => x0.writeText(x1),
_1305: x0 => x0.altKey,
_1306: x0 => x0.code,
_1307: x0 => x0.ctrlKey,
_1308: x0 => x0.key,
_1309: x0 => x0.keyCode,
_1310: x0 => x0.location,
_1311: x0 => x0.metaKey,
_1312: x0 => x0.repeat,
_1313: x0 => x0.shiftKey,
_1314: x0 => x0.isComposing,
_1315: (x0,x1) => x0.getModifierState(x1),
_1316: x0 => x0.state,
_1319: (x0,x1) => x0.go(x1),
_1320: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
_1321: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
_1322: x0 => x0.pathname,
_1323: x0 => x0.search,
_1324: x0 => x0.hash,
_1327: x0 => x0.state,
_1333: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1333(f,arguments.length,x0,x1) }),
_1335: (x0,x1,x2) => x0.observe(x1,x2),
_1338: x0 => x0.attributeName,
_1339: x0 => x0.type,
_1340: x0 => x0.matches,
_1344: x0 => x0.matches,
_1345: x0 => x0.relatedTarget,
_1346: x0 => x0.clientX,
_1347: x0 => x0.clientY,
_1348: x0 => x0.offsetX,
_1349: x0 => x0.offsetY,
_1352: x0 => x0.button,
_1353: x0 => x0.buttons,
_1354: x0 => x0.ctrlKey,
_1355: (x0,x1) => x0.getModifierState(x1),
_1356: x0 => x0.pointerId,
_1357: x0 => x0.pointerType,
_1358: x0 => x0.pressure,
_1359: x0 => x0.tiltX,
_1360: x0 => x0.tiltY,
_1361: x0 => x0.getCoalescedEvents(),
_1362: x0 => x0.deltaX,
_1363: x0 => x0.deltaY,
_1364: x0 => x0.wheelDeltaX,
_1365: x0 => x0.wheelDeltaY,
_1366: x0 => x0.deltaMode,
_1371: x0 => x0.changedTouches,
_1373: x0 => x0.clientX,
_1374: x0 => x0.clientY,
_1375: x0 => x0.data,
_1376: (x0,x1) => x0.type = x1,
_1377: (x0,x1) => x0.max = x1,
_1378: (x0,x1) => x0.min = x1,
_1379: (x0,x1) => x0.value = x1,
_1380: x0 => x0.value,
_1381: x0 => x0.disabled,
_1382: (x0,x1) => x0.disabled = x1,
_1383: (x0,x1) => x0.placeholder = x1,
_1384: (x0,x1) => x0.name = x1,
_1385: (x0,x1) => x0.autocomplete = x1,
_1386: x0 => x0.selectionDirection,
_1387: x0 => x0.selectionStart,
_1388: x0 => x0.selectionEnd,
_1392: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
_1399: (x0,x1) => x0.add(x1),
_1402: (x0,x1) => x0.noValidate = x1,
_1403: (x0,x1) => x0.method = x1,
_1404: (x0,x1) => x0.action = x1,
_1409: (x0,x1) => x0.getContext(x1),
_1412: x0 => x0.convertToBlob(),
_1431: x0 => x0.orientation,
_1432: x0 => x0.width,
_1433: x0 => x0.height,
_1434: (x0,x1) => x0.lock(x1),
_1451: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1451(f,arguments.length,x0,x1) }),
_1461: x0 => x0.length,
_1462: (x0,x1) => x0.item(x1),
_1463: x0 => x0.length,
_1464: (x0,x1) => x0.item(x1),
_1465: x0 => x0.iterator,
_1466: x0 => x0.Segmenter,
_1467: x0 => x0.v8BreakIterator,
_1470: x0 => x0.done,
_1471: x0 => x0.value,
_1472: x0 => x0.index,
_1476: (x0,x1) => x0.adoptText(x1),
_1478: x0 => x0.first(),
_1479: x0 => x0.next(),
_1480: x0 => x0.current(),
_1493: x0 => x0.hostElement,
_1494: x0 => x0.viewConstraints,
_1496: x0 => x0.maxHeight,
_1497: x0 => x0.maxWidth,
_1498: x0 => x0.minHeight,
_1499: x0 => x0.minWidth,
_1500: x0 => x0.loader,
_1501: () => globalThis._flutter,
_1502: (x0,x1) => x0.didCreateEngineInitializer(x1),
_1503: (x0,x1,x2) => x0.call(x1,x2),
_1504: () => globalThis.Promise,
_1505: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1505(f,arguments.length,x0,x1) }),
_1508: x0 => x0.length,
_1511: x0 => x0.tracks,
_1515: x0 => x0.image,
_1520: x0 => x0.codedWidth,
_1521: x0 => x0.codedHeight,
_1524: x0 => x0.duration,
_1528: x0 => x0.ready,
_1529: x0 => x0.selectedTrack,
_1530: x0 => x0.repetitionCount,
_1531: x0 => x0.frameCount,
_1576: (x0,x1,x2) => x0.call(x1,x2),
_1577: (x0,x1) => x0.postMessage(x1),
_1578: (x0,x1) => x0.postMessage(x1),
_1579: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1579(f,arguments.length,x0) }),
_1580: (x0,x1) => x0.addListener(x1),
_1581: (x0,x1) => x0.postMessage(x1),
_1582: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1582(f,arguments.length,x0) }),
_1583: (x0,x1) => x0.removeListener(x1),
_1584: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1584(f,arguments.length,x0,x1) }),
_1585: (x0,x1) => x0.addListener(x1),
_1586: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1586(f,arguments.length,x0) }),
_1587: (x0,x1) => x0.addListener(x1),
_1588: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1588(f,arguments.length,x0,x1,x2) }),
_1589: (x0,x1) => x0.addListener(x1),
_1590: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1590(f,arguments.length,x0) }),
_1591: (x0,x1) => x0.addListener(x1),
_1592: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1592(f,arguments.length,x0) }),
_1593: (x0,x1) => x0.addListener(x1),
_1611: x0 => new BarcodeDetector(x0),
_1640: x0 => new Array(x0),
_1647: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1647(f,arguments.length,x0) }),
_1648: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1648(f,arguments.length,x0) }),
_1673: (decoder, codeUnits) => decoder.decode(codeUnits),
_1674: () => new TextDecoder("utf-8", {fatal: true}),
_1675: () => new TextDecoder("utf-8", {fatal: false}),
_1676: v => v.toString(),
_1677: (d, digits) => d.toFixed(digits),
_1681: x0 => new WeakRef(x0),
_1682: x0 => x0.deref(),
_1688: Date.now,
_1690: s => new Date(s * 1000).getTimezoneOffset() * 60 ,
_1691: s => {
      if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
        return NaN;
      }
      return parseFloat(s);
    },
_1692: () => {
          let stackString = new Error().stack.toString();
          let frames = stackString.split('\n');
          let drop = 2;
          if (frames[0] === 'Error') {
              drop += 1;
          }
          return frames.slice(drop).join('\n');
        },
_1693: () => typeof dartUseDateNowForTicks !== "undefined",
_1694: () => 1000 * performance.now(),
_1695: () => Date.now(),
_1696: () => {
      // On browsers return `globalThis.location.href`
      if (globalThis.location != null) {
        return globalThis.location.href;
      }
      return null;
    },
_1697: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
_1698: () => new WeakMap(),
_1699: (map, o) => map.get(o),
_1700: (map, o, v) => map.set(o, v),
_1701: () => globalThis.WeakRef,
_1712: s => JSON.stringify(s),
_1713: s => printToConsole(s),
_1714: a => a.join(''),
_1715: (o, a, b) => o.replace(a, b),
_1717: (s, t) => s.split(t),
_1718: s => s.toLowerCase(),
_1719: s => s.toUpperCase(),
_1720: s => s.trim(),
_1721: s => s.trimLeft(),
_1722: s => s.trimRight(),
_1723: (s, n) => s.repeat(n),
_1724: (s, p, i) => s.indexOf(p, i),
_1725: (s, p, i) => s.lastIndexOf(p, i),
_1726: (s) => s.replace(/\$/g, "$$$$"),
_1727: Object.is,
_1728: s => s.toUpperCase(),
_1729: s => s.toLowerCase(),
_1730: (a, i) => a.push(i),
_1731: (a, i) => a.splice(i, 1)[0],
_1733: (a, l) => a.length = l,
_1734: a => a.pop(),
_1735: (a, i) => a.splice(i, 1),
_1737: (a, s) => a.join(s),
_1738: (a, s, e) => a.slice(s, e),
_1740: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
_1741: a => a.length,
_1743: (a, i) => a[i],
_1744: (a, i, v) => a[i] = v,
_1746: (o, offsetInBytes, lengthInBytes) => {
      var dst = new ArrayBuffer(lengthInBytes);
      new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
      return new DataView(dst);
    },
_1747: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_1748: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_1749: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_1750: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_1751: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_1752: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_1753: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_1755: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
_1756: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_1757: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_1758: (t, s) => t.set(s),
_1760: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_1762: o => o.buffer,
_1763: o => o.byteOffset,
_1764: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_1765: (b, o) => new DataView(b, o),
_1766: (b, o, l) => new DataView(b, o, l),
_1767: Function.prototype.call.bind(DataView.prototype.getUint8),
_1768: Function.prototype.call.bind(DataView.prototype.setUint8),
_1769: Function.prototype.call.bind(DataView.prototype.getInt8),
_1770: Function.prototype.call.bind(DataView.prototype.setInt8),
_1771: Function.prototype.call.bind(DataView.prototype.getUint16),
_1772: Function.prototype.call.bind(DataView.prototype.setUint16),
_1773: Function.prototype.call.bind(DataView.prototype.getInt16),
_1774: Function.prototype.call.bind(DataView.prototype.setInt16),
_1775: Function.prototype.call.bind(DataView.prototype.getUint32),
_1776: Function.prototype.call.bind(DataView.prototype.setUint32),
_1777: Function.prototype.call.bind(DataView.prototype.getInt32),
_1778: Function.prototype.call.bind(DataView.prototype.setInt32),
_1781: Function.prototype.call.bind(DataView.prototype.getBigInt64),
_1782: Function.prototype.call.bind(DataView.prototype.setBigInt64),
_1783: Function.prototype.call.bind(DataView.prototype.getFloat32),
_1784: Function.prototype.call.bind(DataView.prototype.setFloat32),
_1785: Function.prototype.call.bind(DataView.prototype.getFloat64),
_1786: Function.prototype.call.bind(DataView.prototype.setFloat64),
_1787: (x0,x1) => x0.getRandomValues(x1),
_1788: x0 => new Uint8Array(x0),
_1789: () => globalThis.crypto,
_1792: () => ({}),
_1793: (x0,x1) => new Worker(x0,x1),
_1794: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1794(f,arguments.length,x0) }),
_1795: (x0,x1,x2) => x0.addEventListener(x1,x2),
_1796: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1796(f,arguments.length,x0) }),
_1797: (x0,x1,x2) => x0.addEventListener(x1,x2),
_1798: (x0,x1) => x0.postMessage(x1),
_1799: (x0,x1,x2) => x0.removeEventListener(x1,x2),
_1800: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1800(f,arguments.length,x0) }),
_1801: (x0,x1,x2) => x0.addEventListener(x1,x2),
_1802: (x0,x1) => x0.postMessage(x1),
_1803: x0 => globalThis.workerListener_ = x0,
_1804: () => globalThis.workerListener_,
_1805: x0 => globalThis.errorListener_ = x0,
_1806: () => globalThis.errorListener_,
_1815: (o, t) => o instanceof t,
_1817: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1817(f,arguments.length,x0) }),
_1818: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1818(f,arguments.length,x0) }),
_1819: o => Object.keys(o),
_1820: (ms, c) =>
              setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
_1821: (handle) => clearTimeout(handle),
_1822: (ms, c) =>
          setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
_1823: (handle) => clearInterval(handle),
_1824: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_1825: () => Date.now(),
_1827: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
_1830: (x0,x1) => x0.send(x1),
_1835: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1835(f,arguments.length,x0) }),
_1836: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1836(f,arguments.length,x0) }),
_1837: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
_1838: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
_1856: () => new XMLHttpRequest(),
_1857: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
_1858: x0 => x0.abort(),
_1859: x0 => x0.getAllResponseHeaders(),
_1861: (x0,x1) => x0.get(x1),
_1862: (x0,x1) => x0.query(x1),
_1865: (x0,x1,x2,x3) => x0.sendMessage(x1,x2,x3),
_1866: x0 => x0.onActivated,
_1868: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11) => ({active: x0,audible: x1,autoDiscardable: x2,currentWindow: x3,discarded: x4,highlighted: x5,index: x6,lastFocusedWindow: x7,muted: x8,pinned: x9,windowId: x10,url: x11}),
_1879: x0 => x0.favIconUrl,
_1886: x0 => x0.id,
_1893: x0 => x0.title,
_1895: x0 => x0.url,
_1914: x0 => x0.windowId,
_1942: (x0,x1) => x0.getCurrent(x1),
_1947: (x0,x1) => ({populate: x0,windowTypes: x1}),
_1963: x0 => x0.id,
_1974: x0 => x0.storage,
_1975: x0 => x0.tabs,
_1976: x0 => x0.runtime,
_1978: x0 => x0.windows,
_1980: x0 => x0.runtime,
_1983: () => globalThis.chrome,
_1984: () => globalThis.chrome,
_1985: () => globalThis.browser,
_1986: () => globalThis.browser,
_1987: (x0,x1) => x0.getItem(x1),
_1988: (x0,x1) => x0.getItem(x1),
_1989: (x0,x1,x2) => x0.setItem(x1,x2),
_1990: x0 => x0.clear(),
_1991: (x0,x1,x2) => x0.setItem(x1,x2),
_1992: (x0,x1,x2) => x0.setItem(x1,x2),
_1994: (x0,x1) => x0.getItem(x1),
_1995: (x0,x1) => x0.removeItem(x1),
_1996: (x0,x1,x2) => x0.setItem(x1,x2),
_1997: x0 => x0.arrayBuffer(),
_1998: x0 => ({type: x0}),
_1999: (x0,x1,x2) => new File(x0,x1,x2),
_2000: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
_2001: () => globalThis.localStorage,
_2005: (x0,x1) => x0.removeItem(x1),
_2008: x0 => globalThis.Object.entries(x0),
_2009: (x0,x1,x2) => ({data: x0,type: x1,additional: x2}),
_2010: x0 => x0.type,
_2011: (x0,x1) => x0.client_id = x1,
_2012: x0 => x0.client_id,
_2013: (x0,x1) => x0.request_id = x1,
_2014: x0 => x0.request_id,
_2015: x0 => x0.data,
_2016: x0 => x0.additional,
_2022: (x0,x1,x2,x3) => x0.sendMessage(x1,x2,x3),
_2024: (x0,x1) => x0.getURL(x1),
_2025: x0 => x0.id,
_2026: x0 => x0.id,
_2028: x0 => x0.onMessage,
_2030: x0 => x0.onConnect,
_2043: x0 => x0.onDisconnect,
_2044: x0 => x0.onMessage,
_2058: (x0,x1,x2) => x0.close(x1,x2),
_2059: x0 => x0.close(),
_2064: () => globalThis.window,
_2067: x0 => x0.BarcodeDetector,
_2068: x0 => x0.navigator,
_2069: x0 => x0.navigator,
_2071: x0 => x0.document,
_2074: (x0,x1) => x0.fetch(x1),
_2078: x0 => x0.focus(),
_2091: (x0,x1) => x0.createElement(x1),
_2092: x0 => x0.body,
_2094: x0 => x0.hasFocus(),
_2095: x0 => globalThis.URL.createObjectURL(x0),
_2096: (x0,x1) => x0.appendChild(x1),
_2097: x0 => x0.click(),
_2098: (x0,x1) => x0.removeChild(x1),
_2101: (x0,x1) => x0.writeText(x1),
_2102: x0 => x0.readText(),
_2105: x0 => x0.mediaDevices,
_2106: x0 => x0.userAgent,
_2107: (x0,x1,x2,x3,x4) => x0.share(x1,x2,x3,x4),
_2108: x0 => x0.clipboard,
_2110: (x0,x1) => x0.getUserMedia(x1),
_2114: (x0,x1) => x0.detect(x1),
_2118: x0 => x0.rawValue,
_2131: (x0,x1) => new Blob(x0,x1),
_2135: x0 => x0.ok,
_2136: x0 => x0.status,
_2137: x0 => x0.arrayBuffer(),
_2138: x0 => x0.text(),
_2149: (x0,x1) => x0.type = x1,
_2166: x0 => x0.data,
_2167: (x0,x1,x2) => x0.addEventListener(x1,x2),
_2168: (x0,x1,x2) => x0.removeEventListener(x1,x2),
_2170: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2170(f,arguments.length,x0) }),
_2183: (x0,x1) => new WebSocket(x0,x1),
_2184: x0 => x0.readyState,
_2186: (x0,x1) => x0.send(x1),
_2188: x0 => x0.local,
_2190: x0 => x0.session,
_2197: (x0,x1) => x0.get(x1),
_2200: (x0,x1) => x0.get(x1),
_2203: (x0,x1) => x0.remove(x1),
_2205: (x0,x1) => x0.remove(x1),
_2209: (x0,x1) => x0.set(x1),
_2214: (s, m) => {
          try {
            return new RegExp(s, m);
          } catch (e) {
            return String(e);
          }
        },
_2215: (x0,x1) => x0.exec(x1),
_2216: (x0,x1) => x0.test(x1),
_2217: (x0,x1) => x0.exec(x1),
_2218: (x0,x1) => x0.exec(x1),
_2219: x0 => x0.pop(),
_2223: (x0,x1,x2) => x0[x1] = x2,
_2225: o => o === undefined,
_2226: o => typeof o === 'boolean',
_2227: o => typeof o === 'number',
_2229: o => typeof o === 'string',
_2232: o => o instanceof Int8Array,
_2233: o => o instanceof Uint8Array,
_2234: o => o instanceof Uint8ClampedArray,
_2235: o => o instanceof Int16Array,
_2236: o => o instanceof Uint16Array,
_2237: o => o instanceof Int32Array,
_2238: o => o instanceof Uint32Array,
_2239: o => o instanceof Float32Array,
_2240: o => o instanceof Float64Array,
_2241: o => o instanceof ArrayBuffer,
_2242: o => o instanceof DataView,
_2243: o => o instanceof Array,
_2244: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_2246: o => {
            const proto = Object.getPrototypeOf(o);
            return proto === Object.prototype || proto === null;
          },
_2247: o => o instanceof RegExp,
_2248: (l, r) => l === r,
_2249: o => o,
_2250: o => o,
_2251: o => o,
_2252: b => !!b,
_2253: o => o.length,
_2256: (o, i) => o[i],
_2257: f => f.dartFunction,
_2258: l => arrayFromDartList(Int8Array, l),
_2259: (data, length) => {
          const jsBytes = new Uint8Array(length);
          const getByte = dartInstance.exports.$uint8ListGet;
          for (let i = 0; i < length; i++) {
            jsBytes[i] = getByte(data, i);
          }
          return jsBytes;
        },
_2260: l => arrayFromDartList(Uint8ClampedArray, l),
_2261: l => arrayFromDartList(Int16Array, l),
_2262: l => arrayFromDartList(Uint16Array, l),
_2263: l => arrayFromDartList(Int32Array, l),
_2264: l => arrayFromDartList(Uint32Array, l),
_2265: l => arrayFromDartList(Float32Array, l),
_2266: l => arrayFromDartList(Float64Array, l),
_2267: (data, length) => {
          const read = dartInstance.exports.$byteDataGetUint8;
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, read(data, i));
          }
          return view;
        },
_2268: l => arrayFromDartList(Array, l),
_2269:       (s, length) => {
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
      }
      ,
_2270:     (s, length) => {
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
    }
    ,
_2271:     (s) => {
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
    }
    ,
_2272: () => ({}),
_2273: () => [],
_2274: l => new Array(l),
_2275: () => globalThis,
_2276: (constructor, args) => {
      const factoryFunction = constructor.bind.apply(
          constructor, [null, ...args]);
      return new factoryFunction();
    },
_2277: (o, p) => p in o,
_2278: (o, p) => o[p],
_2279: (o, p, v) => o[p] = v,
_2280: (o, m, a) => o[m].apply(o, a),
_2282: o => String(o),
_2283: (p, s, f) => p.then(s, f),
_2284: s => {
      if (/[[\]{}()*+?.\\^$|]/.test(s)) {
          s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
      }
      return s;
    },
_2287: x0 => x0.index,
_2289: x0 => x0.length,
_2291: (x0,x1) => x0[x1],
_2292: (x0,x1) => x0.exec(x1),
_2294: x0 => x0.flags,
_2295: x0 => x0.multiline,
_2296: x0 => x0.ignoreCase,
_2297: x0 => x0.unicode,
_2298: x0 => x0.dotAll,
_2299: (x0,x1) => x0.lastIndex = x1,
_2338: (x0,x1) => x0.withCredentials = x1,
_2340: x0 => x0.responseURL,
_2341: x0 => x0.status,
_2342: x0 => x0.statusText,
_2344: (x0,x1) => x0.responseType = x1,
_2345: x0 => x0.response,
_15207: x0 => x0.id,
_15208: (x0,x1) => x0.id = x1,
_15213: (x0,x1) => x0.autoplay = x1,
_15219: (x0,x1) => x0.href = x1,
_15220: (x0,x1) => x0.target = x1,
_15221: (x0,x1) => x0.download = x1,
_15225: (x0,x1) => x0.srcObject = x1,
_15239: x0 => x0.stop(),
_15241: x0 => x0.getTracks()
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

    dartInstance = await WebAssembly.instantiate(await modulePromise, {
        ...baseImports,
        ...(await importObjectPromise),
        "wasm:js-string": jsStringPolyfill,
    });

    return dartInstance;
}

// Call the main function for the instantiated module
// `moduleInstance` is the instantiated dart2wasm module
// `args` are any arguments that should be passed into the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

