import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';

class CosmosWeb3MessagesInfo {
  final String typeUrl;
  final String value;
  final String? content;
  const CosmosWeb3MessagesInfo(
      {required this.content, required this.typeUrl, required this.value});
}

class CosmosWeb3SimulateMessageResponse {
  final String typeUrl;
  final String response;
  final String? content;
  const CosmosWeb3SimulateMessageResponse(
      {required this.typeUrl, required this.response, required this.content});
}

class CosmosWeb3SimulateEvent {
  final String type;
  final String key;
  final String value;
  const CosmosWeb3SimulateEvent(
      {required this.key, required this.value, required this.type});
}

class CosmosWeb3SimulateInfos {
  final BigInt gasUsed;
  final BigInt? gasWanted;
  final String? log;
  final String? content;
  final List<CosmosWeb3SimulateMessageResponse> messageResponse;
  final List<CosmosWeb3SimulateEvent> events;
  CosmosWeb3SimulateInfos._({
    required this.gasUsed,
    required this.gasWanted,
    required this.content,
    required List<CosmosWeb3SimulateMessageResponse> messageResponse,
    required List<CosmosWeb3SimulateEvent> events,
    required this.log,
  })  : messageResponse = messageResponse.immutable,
        events = events.immutable;
  factory CosmosWeb3SimulateInfos({
    required SimulateResponse simulate,
    required List<CosmosMessage> txMessages,
  }) {
    final List<CosmosWeb3SimulateEvent> events = [];
    for (final i in simulate.result.events) {
      for (final e in i.attributes) {
        if (e.key == null || e.value == null) continue;
        events.add(CosmosWeb3SimulateEvent(
            key: e.key!, value: e.value!, type: i.type));
      }
    }
    final List<CosmosWeb3SimulateMessageResponse> msgResult = [];
    bool canDecodeResult =
        txMessages.length == simulate.result.msgResponses.length;

    for (int i = 0; i < simulate.result.msgResponses.length; i++) {
      final response = simulate.result.msgResponses[i];
      final String type = response.typeUrl.typeUrl;
      final String value = response.toBase64;
      String? content;
      if (canDecodeResult) {
        final msg = txMessages[i];
        if (msg is ServiceMessage) {
          content = MethodUtils.nullOnException(() {
            final responseMesssage =
                msg.onResponse((response as AnyBytesMessage).value).toJson();
            if (responseMesssage.isEmpty) return null;
            return StringUtils.fromJson(responseMesssage,
                indent: '', toStringEncodable: true);
          });
        }
      }
      msgResult.add(CosmosWeb3SimulateMessageResponse(
          typeUrl: type, response: value, content: content));
    }
    String log = simulate.result.log ?? '';
    return CosmosWeb3SimulateInfos._(
        gasUsed: simulate.gasInfo.gasUsed,
        gasWanted: simulate.gasInfo.gasWanted,
        messageResponse: msgResult,
        events: events,
        log: log.isEmpty ? null : log,
        content: MethodUtils.nullOnException(() => StringUtils.fromJson(
            simulate.toJson(),
            indent: '',
            toStringEncodable: true)));
  }
}
