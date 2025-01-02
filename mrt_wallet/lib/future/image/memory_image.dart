import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';

class CacheMemoryImageProvider extends ImageProvider<CacheMemoryImageProvider>
    with CryptoWokerImpl, HttpImpl {
  final APPImageInfo image;
  CacheMemoryImageProvider(this.image);

  @override
  ImageStreamCompleter loadImage(
      CacheMemoryImageProvider key, ImageDecoderCallback decode) {
    StreamController<ImageChunkEvent>? chunkEvent;
    if (image.type == ContentType.favIcon ||
        image.type == ContentType.network ||
        image.type == ContentType.lazy) {
      chunkEvent = StreamController<ImageChunkEvent>();
      chunkEvent.add(
          ImageChunkEvent(cumulativeBytesLoaded: 0, expectedTotalBytes: 100));
    }
    final Future<Codec> codec = _loadAsync(
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
        debugLabel: image.toString(),
        informationCollector: () sync* {
          yield ErrorDescription('Tag: ${image.toString()}');
        },
        chunkEvents: chunkEvent?.stream);
  }

  Future<Codec> _loadAsync(
      {required ImageDecoderCallback decode,
      required OnStreamReapose onStreamResponse,
      required DynamicVoid onDone}) async {
    ImmutableBuffer buffer;
    try {
      // final cacheKey = await image.loadCacheKey();
      String uri = await image.loadUrl();
      if (uri.isEmpty) {
        throw StateError('${image.type} cannot be loaded as an image.');
      }
      switch (image.type) {
        case ContentType.local:
          final bytes = await PlatformUtils.loadAssets(uri);
          buffer =
              await ImmutableBuffer.fromUint8List(Uint8List.fromList(bytes));
          break;
        case ContentType.hex:
          final data = Uint8List.fromList(await crypto.hexToBytes(uri));
          buffer = await ImmutableBuffer.fromUint8List(data);
          break;
        case ContentType.favIcon:
        case ContentType.network:
        case ContentType.lazy:
          if (image.type == ContentType.favIcon) {
            uri = LinkConst.faviIconGenerator + uri;
          }
          final fetch =
              await makeStream(uri: uri, onProgress: onStreamResponse);
          buffer = await ImmutableBuffer.fromUint8List(
              Uint8List.fromList(fetch.hasResult ? fetch.result : const []));
          break;
        default:
          throw StateError('${image.type} cannot be loaded as an image.');
      }

      return await decode(buffer);
    } finally {
      onDone();
    }
  }

  @override
  Future<CacheMemoryImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheMemoryImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CacheMemoryImageProvider && other.image == image;
  }

  @override
  int get hashCode => image.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CacheImageProvider')}("${image.hashCode}")';
}
