import 'dart:async';

class SocketRequestCompeleter {
  SocketRequestCompeleter(this.params, this.id);
  final Completer completer = Completer();
  final String params;
  final int id;
}
