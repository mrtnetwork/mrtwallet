import 'dart:async';

class SocketRequestCompleter {
  SocketRequestCompleter(this.params, this.id);
  final Completer completer = Completer();
  final List<int> params;
  final int id;
}
