import 'dart:async';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models.dart';

class WorkerMessageCompleter {
  final int id;
  WorkerMessageCompleter(this.id);
  final Completer<MessageArgs> _messageCompleter = Completer();

  void complete(WorkerResponseMessage message) {
    _messageCompleter.complete(message.args);
  }

  Future<MessageArgs> getResult(
      {Duration timeout = const Duration(seconds: 60)}) async {
    final result = await _messageCompleter.future.timeout(timeout);
    return result;
  }
}
