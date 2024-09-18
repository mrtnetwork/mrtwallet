import 'dart:async';
import 'package:blockchain_utils/uuid/uuid.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'requests.dart';

class MessageCompleterHandler {
  final Map<String, MessageCompleter> _awaitingMessages = {};

  MessageCompleter get nextRequest {
    final requestId = UUID.generateUUIDv4();
    final completer = MessageCompleter(requestId);
    _awaitingMessages[requestId] = completer;
    return completer;
  }

  bool hasRequest(String id) {
    return _awaitingMessages.containsKey(id);
  }

  void complete(
      {required Web3MessageCore response, required String? requestId}) {
    final completer = _awaitingMessages.remove(requestId);
    completer?.complete(response);
  }
}

class MessageCompleter {
  final String id;
  MessageCompleter(this.id);
  final Completer<Web3MessageCore> _completer = Completer();
  Future<Web3MessageCore> get wait => _completer.future;
  void complete(Web3MessageCore value) {
    _completer.complete(value);
  }
}

class PageRequestCompeleter {
  final String id;
  PageRequestCompeleter._(this.id);
  factory PageRequestCompeleter.nextRequest() {
    return PageRequestCompeleter._(UUID.generateUUIDv4());
  }
  final Completer<WalletMessageResponse> _completer = Completer();

  Future<WalletMessageResponse> get wait => _completer.future;
  void completeMessage(WalletMessageResponse response) {
    _completer.complete(response);
  }
}
