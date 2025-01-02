import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class StreamRequestHexToBytes extends IsolateStreamRequest<List<int>, String> {
  StreamRequestHexToBytes();
  factory StreamRequestHexToBytes.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: StreamIsolateMethod.test.tag);
    return StreamRequestHexToBytes();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([]), method.tag);
  }

  @override
  StreamIsolateMethod get method => StreamIsolateMethod.test;

  @override
  void handleIsolateData(
      {required String param,
      required EventSink<MessageArgsStream> sink,
      required String streamId,
      List<int>? encryptedPart}) async {
    while (!closed) {
      sink.add(MessageArgsStream(
          data: BytesUtils.fromHexString(param), streamId: streamId));
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void handleData(
      {required String param,
      required EventSink<List<int>> sink,
      required String streamId,
      List<int>? encryptedPart}) async {
    while (true) {
      sink.add(BytesUtils.fromHexString(param));
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  List<int> parsResult(MessageArgsStream result) {
    return result.data!;
  }

  @override
  Stream<List<int>> result({List<int>? encryptedPart}) {
    throw UnimplementedError();
  }

  @override
  MessageArgsStream toRequest(
      {required String message, required String streamId}) {
    return MessageArgsStream(
        data: BytesUtils.fromHexString(message), streamId: streamId);
  }

  @override
  void add(MessageArgsStream args) {
    super.add(args);
    switch (args.method) {
      case MessageArgsStreamMethod.data:
        streamController?.add(BytesUtils.toHexString(args.data!));
        break;
      default:
    }
  }
}
