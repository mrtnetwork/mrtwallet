import 'dart:js_interop';

@JS("MediaStreamTrack")
extension type MediaStreamTrack._(JSObject _) implements JSObject {
  external factory MediaStreamTrack();
  external String? get contentHint;
  external bool get enabled;

  external String? get id;
  external String? get kind;
  external String? get label;
  external bool? get muted;
  @JS("stop")
  external void stop();
}

@JS("MediaStream")
extension type MediaStream._(JSObject _) implements JSObject {
  external factory MediaStream();
  external JSArray<MediaStreamTrack> getTracks();
  external bool get enabled;

  external String? get id;
  external String? get kind;
  external String? get label;
  external bool? get muted;

  void stop() async {
    final dartTracks = getTracks().toDart;
    for (final i in dartTracks) {
      i.stop();
    }
  }
}
