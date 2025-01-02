import 'dart:async';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';

class WorkerMessageCompleter {
  final int id;
  WorkerMessageCompleter(this.id);
  final Completer<CborMessageArgs> _messageCompleter = Completer();

  void complete(CborMessageArgs message) {
    _messageCompleter.complete(message);
  }

  void close() {
    _messageCompleter
        .completeError(WalletException("isolate_terminated_error"));
  }

  Future<CborMessageArgs> getResult({Duration? timeout}) async {
    final result = await _messageCompleter.future
        .timeout(timeout ?? const Duration(seconds: 120));
    return result;
  }
}
