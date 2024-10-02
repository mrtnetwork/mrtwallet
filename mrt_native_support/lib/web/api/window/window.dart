import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:mrt_native_support/web/api/chrome/chrome.dart';

import 'html.dart';
import 'media_stream.dart';
// import '../chrome/api/core.dart';

@JS("cloneInto")
external T _cloneInto<T extends JSAny>(T? object, JSAny? where);

@JS("cloneInto")
external JSFunction? get cloneInto;
// @JS("browser")
// external JSAny? get _browser;

@JS("console")
external JSConsole get jsConsole;

@JS("JSON")
external JSON get jsJson;
@JS("window")
external Window get jsWindow;
@JS("window")
extension type Window._(JSObject _) implements WebEventStream {
  external factory Window();
  @JS("BarcodeDetector")
  external BarcodeDetector? get barcode;
  @JS("navigator")
  external JSNavigator get navigator;
  @JS("navigator")
  external JSNavigator? get navigatorNullable;
  @JS("URL")
  external URL get url;
  @JS("document")
  external Document get document;
  @JS("location")
  external Location get location;

  @JS("open")
  external JSAny? open(String? url, String? target, String? windowFeatures);
  @JS("fetch")
  external JSPromise<Response> fetch(String resource);

  @JS("webkit")
  external WebKit get webkit;

  @JS("postMessage")
  external void postMessage(JSAny message);
  @JS("focus")
  external void focus();

  Future<Response> fetch_(String url) async {
    final future = fetch(url);
    final result = await future.toDart;
    return result;
  }
}

@JS()
extension type WebKitMrt._(JSObject _) implements JSAny {
  external void postMessage(JSAny? message);
}
@JS()
extension type WebKitMessageHandlers._(JSObject _) implements JSAny {
  @JS("MRT")
  external WebKitMrt get mrt;
}
@JS("webkit")
extension type WebKit._(JSObject _) implements JSAny {
  @JS("messageHandlers")
  external WebKitMessageHandlers get messageHandlers;
}

@JS("location")
extension type Location._(JSObject _) implements WebEventStream {
  external factory Location();
  external String get href;
  external String get host;
  @JS("hostname")
  external String get hostName;
  external String get port;
  external String get origin;
}

@JS("Document")
extension type Document._(JSObject _) implements JSObject, WebEventStream {
  external factory Document();
  @JS("createElement")
  external T createElement<T extends HTMLElement>(String tagName);
  @JS("body")
  external JSNode get body;
  external JSAny? get defaultView;
  @JS("hasFocus")
  external bool hasFocus();

  HTMLVideoElement createVideoElement({String type = "video"}) {
    return createElement(type);
  }

  String downloadFile(
      {required List<int> fileBytes, required String fileName}) {
    final blob = Blob.fromBytes(fileBytes);
    final url = URL.createObjectURL(blob);
    final HTMLAnchorElement anchor = createElement("a");
    anchor.target = "download";
    anchor.href = url;
    anchor.download = fileName;
    jsWindow.document.body.appendChild(anchor);
    anchor.click();
    jsWindow.document.body.removeChild(anchor);
    return url;
  }
}
@JS("Clipboard")
extension type Clipboard._(JSObject _) implements JSObject {
  external factory Clipboard();
  external JSPromise writeText(String? text);
  external JSPromise<JSString?> readText();
  Future<bool> writeText_(String text) async {
    try {
      if (!jsWindow.document.hasFocus()) {
        jsWindow.focus();
      }
      await writeText(text).toDart;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> readText_() async {
    try {
      final text = await readText().toDart;
      return text?.toDart;
    } catch (e) {
      return null;
    }
  }
}
@JS("navigator")
extension type JSNavigator._(JSObject _) implements JSObject {
  external factory JSNavigator();
  external MediaDevices get mediaDevices;
  external String? get userAgent;
  bool get isFirefox => userAgent?.contains("Firefox") ?? false;
  bool get isWebKit => userAgent?.contains("AppleWebKit") ?? false;
  external JSPromise share(
      String? url, String? text, String? title, JSArray<JSFile>? files);
  external Clipboard? get clipboard;

  /// navigator.clipboard.writeText(text)
  Future<void> share_({
    required List<JSFile> files,
    String? url,
    String? text,
    String? title,
  }) async {
    final future = share(url, text, title, files.toJS).toDart;
    await future;
  }
}
@JS("MediaDevices")
extension type MediaDevices._(JSObject _) implements JSObject {
  external factory MediaDevices();
  @JS("getUserMedia")
  external JSPromise<MediaStream> getUserMedia(JSAny? constraints);

  Future<MediaStream> getUserMedia_(
      {bool video = true,
      bool audio = false,
      Map<String, dynamic>? constraints}) async {
    final future =
        getUserMedia((constraints ?? {"video": video, "audio": audio}).jsify())
            .toDart;
    return await future;
  }
}

@JS("BarcodeDetector")
extension type BarcodeDetector._(JSObject _) implements JSObject {
  external factory BarcodeDetector(JSAny? formats);
  factory BarcodeDetector.withFormats(List<String> formats) {
    return BarcodeDetector({"formats": formats}.jsify());
  }
  external JSPromise<JSArray<DetectedBarcode>> detect(
      HTMLVideoElement imageBitmapSource);
  Stream<String> stream(HTMLVideoElement element,
      {Duration interval = const Duration(milliseconds: 300)}) async* {
    yield* Stream.periodic(interval)
        .asyncMap((_) async {
          final future = (await detect(element).toDart).toDart;
          if (future.isNotEmpty && future.first.rawValue != null) {
            return future.first.rawValue!;
          }
          return null;
        })
        .where((event) => event != null)
        .cast<String>();
  }
}
@JS()
extension type BarcodeDetectorOptions._(JSObject _) implements JSObject {
  external factory BarcodeDetectorOptions(JSArray<JSString>? formats);
  external JSArray<JSString>? get formats;
}
@JS("BarcodeDetector")
extension type DetectedBarcode._(JSObject _) implements JSObject {
  external factory DetectedBarcode();
  external String? get rawValue;
  external String? get format;
}
@JS("URL")
extension type URL._(JSObject _) implements JSObject {
  external factory URL();
  @JS("createObjectURL")
  external static String createObjectURL(Blob object);
  @JS("createObjectURL")
  external static String createObjectURLFromFile(JSFile object);
}

extension type JSFileOption._(JSObject _) implements JSObject {
  external JSFileOption({String? type, String? endings, int? lastModified});
  external String? get type;
  external String? get endings;
  external int? get lastModified;
}

@JS("File")
extension type JSFile._(JSObject _) implements JSObject {
  external JSFile(
      JSArray<JSArrayBuffer> fileBits, String fileName, JSFileOption? options);
  external JSArray<JSArrayBuffer>? get fileBits;
  external String? get fileName;
  external JSFileOption? get options;
}

@JS("Blob")
extension type Blob._(JSObject _) implements JSObject {
  external factory Blob(JSArray<JSArrayBuffer> blobParts, JSObject? options);
  factory Blob.fromBytes(List<int> bytes) {
    final data = Uint8List.fromList(bytes).buffer.toJS;
    return Blob([data].toJS, null);
  }
  external JSArrayBuffer? get blobParts;
  external JSObject? get options;
}

@JS("Response")
extension type Response._(JSObject _) implements JSObject {
  external factory Response();

  @JS("ok")
  external bool get ok;
  @JS("status")
  external int get status;
  @JS("arrayBuffer")
  external JSPromise<JSArrayBuffer> arrayBuffer();
  @JS("text")
  external JSPromise<JSString> text();

  Future<ByteBuffer> arrayBuffer_() async {
    final data = await arrayBuffer().toDart;
    return data.toDart;
  }

  Future<String> text_() async {
    final data = await text().toDart;
    return data.toDart;
  }
}
@JS("Worker")
extension type Worker._(JSObject _) implements JSObject, WebEventStream {
  external factory Worker(String? aURL, WorkerOptions? options);
  external String? get aURL;
  external WorkerOptions? get options;
  @JS("addEventListener")
  external void addEventListener(String type, JSFunction callback);
  @JS("removeEventListener")
  external void removeEventListener(String type, JSFunction callback);
  external void postMessage(JSAny message);
}
extension type WorkerOptions._(JSObject _) implements JSObject {
  external factory WorkerOptions(
      {String? type, String? credentials, String? name});

  external String? get type;
  external set type(String? type);
  external String? get credentials;
  external set credentials(String? type);
  external String? get name;
  external set name(String? type);
}
@JS("Event")
extension type WebEvent._(JSObject _) implements EventInit {
  external factory WebEvent(String? type, EventInit? options);
  external String? get type;
}
@JS()
extension type EventInit._(JSObject _) implements JSObject {
  external bool? get bubbles;
  external bool? get cancelable;
  external bool? get composed;
  external JSAny? get detail;
  external set bubbles(bool? bubbles);
  external set cancelable(bool? cancelable);
  external set composed(bool? composed);
  external set detail(JSAny? detail);
  external factory EventInit(
      {bool? bubbles, bool? cancelable, bool? composed, JSAny? detail});

  List<int>? detailBytes() {
    try {
      return List<int>.from(detail.dartify() as List);
    } catch (e) {
      return null;
    }
  }
}
@JS("Event")
extension type MessageEvent._(JSObject _) implements WebEvent {
  external factory MessageEvent();
  external JSAny? get data;
}
extension type WebEventStream._(JSObject _) {
  @JS("addEventListener")
  external void addEventListener(String type, JSFunction callback);
  @JS("removeEventListener")
  external void removeEventListener(String type, JSFunction callback);

  external void dispatchEvent(WebEvent event);

  Stream<T> stream<T>(String type) {
    final StreamController<T> controller = StreamController();
    final callback = (MessageEvent event) {
      controller.add(event.data?.dartify() as T);
    }.toJS;
    controller.onCancel = () {
      removeEventListener(type, callback);
    };
    addEventListener(type, callback);

    return controller.stream;
  }

  Stream<JSAny> streamObject<T>(String type) {
    final StreamController<JSAny> controller = StreamController();
    final callback = (JSAny content) {
      controller.add(content);
    }.toJS;
    controller.onCancel = () {
      removeEventListener(type, callback);
    };
    addEventListener(type, callback);

    return controller.stream;
  }
}

@JS("CustomEvent")
extension type CustomEvent._(JSObject _) implements WebEvent {
  external factory CustomEvent(String? type, EventInit? options);
  factory CustomEvent.create(
      {required String? type,
      required JSAny? eventData,
      bool bubbles = true,
      bool cancelable = false,
      bool clone = false}) {
    if (clone && isExtension && cloneInto != null) {
      eventData = _cloneInto(eventData, jsWindow.document.defaultView);
    }

    return CustomEvent(
      type,
      EventInit(bubbles: bubbles, cancelable: cancelable, detail: eventData),
    );
  }
}

@JS("JSON")
extension type JSON._(JSObject _) implements JSObject {
  external factory JSON();
  @JS("parse")
  external JSObject? parse(String? text);
  @JS("stringify")
  external String stringify(JSAny? object);
}
@JS("console")
extension type JSConsole._(JSObject _) implements JSObject {
  external factory JSConsole();
  external void log(String? text);
  external void debug(String? text);
  external void info(String? text);
  external void error(String? text);
  @JS("error")
  external void errorObject(JSAny? obj);
}
