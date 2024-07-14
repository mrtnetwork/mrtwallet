import 'dart:async';
import 'package:mrt_wallet/wroker/messages/argruments/argruments.dart';
import '../response/response.dart';

class WorkerMessageCompleter {
  final int id;
  WorkerMessageCompleter(this.id);
  final Completer<MessageArgs> _messageCompleter = Completer();

  void complete(WorkerMessageResponse message) {
    _messageCompleter.complete(message.args);
  }

  Future<MessageArgs> getResult(
      {Duration timeout = const Duration(seconds: 10)}) async {
    final result = await _messageCompleter.future.timeout(timeout);
    return result;
  }
}
