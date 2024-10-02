import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';

class CacheMemoryImageProvider extends ImageProvider<CacheMemoryImageProvider>
    with CryptoWokerImpl {
  final APPImage image;
  CacheMemoryImageProvider(this.image);

  @override
  ImageStreamCompleter loadImage(
      CacheMemoryImageProvider key, ImageDecoderCallback decode) {
    StreamController<ImageChunkEvent>? chunkEvent;
    if (image.type == ContentType.favIcon) {
      chunkEvent = StreamController<ImageChunkEvent>();
    }
    Future<Codec> codec = _loadAsync(
        decode: decode,
        onStreamResponse: (cumulativeBytesLoaded, expectedTotalBytes) {
          chunkEvent?.add(ImageChunkEvent(
              cumulativeBytesLoaded: cumulativeBytesLoaded,
              expectedTotalBytes: expectedTotalBytes));
        },
        onDone: () {
          chunkEvent?.close();
          chunkEvent = null;
        });
    return MultiFrameImageStreamCompleter(
        codec: codec,
        scale: 1.0,
        debugLabel: image.cacheKey,
        informationCollector: () sync* {
          yield ErrorDescription('Tag: ${image.cacheKey}');
        },
        chunkEvents: chunkEvent?.stream);
  }

  Future<Codec> _loadAsync(
      {required ImageDecoderCallback decode,
      required OnStreamReapose onStreamResponse,
      required DynamicVoid onDone}) async {
    ImmutableBuffer buffer;
    switch (image.type) {
      case ContentType.local:
        final bytes = await PlatformUtils.loadAssets(image.uri);
        buffer = await ImmutableBuffer.fromUint8List(Uint8List.fromList(bytes));
        break;
      case ContentType.hex:
        final data = Uint8List.fromList(await crypto.hexToBytes(image.uri));
        buffer = await ImmutableBuffer.fromUint8List(data);
        break;
      case ContentType.favIcon:
      case ContentType.network:
        String url = image.uri;
        if (image.type == ContentType.favIcon) {
          url = LinkConst.faviIconGenerator + image.uri;
        }
        final fetch =
            await HttpUtils.getStream(url, response: onStreamResponse);
        onDone();
        buffer = await ImmutableBuffer.fromUint8List(
            Uint8List.fromList(fetch.hasResult ? fetch.result : const []));
        break;
      default:
        throw StateError('${image.type} cannot be loaded as an image.');
    }
    return await decode(buffer);
  }

  @override
  Future<CacheMemoryImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheMemoryImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CacheMemoryImageProvider &&
        other.image.cacheKey == image.cacheKey;
  }

  @override
  int get hashCode => image.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CacheImageProvider')}("${image.hashCode}")';
}
