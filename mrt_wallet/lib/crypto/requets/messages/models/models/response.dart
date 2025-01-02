// import 'package:blockchain_utils/blockchain_utils.dart';
// import 'package:mrt_wallet/app/serialization/serialization.dart';
// import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
// import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

// // abstract class IsolateResponseMessage<T, ARGS extends IsolateMessageArgs> {
// //   abstract final ARGS args;
// //   T encode();
// // }

// class IsolateCborResponseMessage with CborSerializable {
//   final CborMessageArgs args;
//   // final int id;
//   const IsolateCborResponseMessage({required this.args, required this.id});
//   factory IsolateCborResponseMessage.deserialize(List<int> bytes) {
//     final CborListValue values = CborSerializable.decodeCborTags(
//         bytes, null, WorkerMessageConst.workerMessagResponse);
//     final int id = values.elementAs(0);
//     final List<int> msgBytes = values.elementAs(1);
//     return IsolateCborResponseMessage(
//         args: CborMessageArgs.deserialize(msgBytes), id: id);
//   }

//   @override
//   CborTagValue toCbor() {
//     return CborTagValue(
//         CborListValue.fixedLength([
//           CborIntValue(id),
//           CborBytesValue(args.toCbor().encode()),
//         ]),
//         WorkerMessageConst.workerMessagResponse);
//   }

//   @override
//   List<int> encode() {
//     return toCbor().encode();
//   }
// }

// // class IsolateJsonResponseMessage
// //     implements IsolateResponseMessage<Map<String, dynamic>, JsonMessageArgs> {
// //   final JsonMessageArgs args;
// //   final int id;
// //   const IsolateJsonResponseMessage({required this.args, required this.id});
// //   factory IsolateJsonResponseMessage.deserialize(Map<String, dynamic> json) {
// //     final int id = json["id"];
// //     return IsolateJsonResponseMessage(
// //         args: JsonMessageArgs.fromJson(json), id: id);
// //   }

// //   @override
// //   Map<String, dynamic> encode() {
// //     return {"id": id, "args": args.toJson()};
// //   }
// // }
