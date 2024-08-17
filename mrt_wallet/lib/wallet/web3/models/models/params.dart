import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';

class ExtentionRequestEvent with CborSerializable {
  final String id;
  final List<int> data;
  final String requestId;
  final String url;
  final int tabId;
  ExtentionRequestEvent({
    required this.id,
    required List<int> data,
    required this.requestId,
    required this.url,
    required this.tabId,
  }) : data = List<int>.unmodifiable(data);
  factory ExtentionRequestEvent.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, hex: hex);
    return ExtentionRequestEvent(
        id: values.elementAt(0),
        data: values.elementAt(1),
        requestId: values.elementAt(2),
        url: values.elementAt(3),
        tabId: values.elementAt(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [id, CborBytesValue(data), requestId, url, tabId]),
        [1]);
  }
}
