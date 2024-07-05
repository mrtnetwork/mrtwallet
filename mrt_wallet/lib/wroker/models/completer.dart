import 'dart:async';
import 'package:mrt_wallet/wroker/models/bytes.dart';
import 'response_message.dart';

class WorkerMessageCompleter {
  final int id;
  WorkerMessageCompleter(this.id);
  final Completer<ArgsBytes> _messageCompleter = Completer();

  void complete(WorkerMessageResponse message) {
    _messageCompleter.complete(message.args);
  }

  Future<ArgsBytes> getResult(
      {Duration timeout = const Duration(seconds: 10)}) async {
    final result = await _messageCompleter.future.timeout(timeout);
    return result;
  }
}
