import 'dart:async';

enum WorkerMode {
  main,
  sync1,
  sync2;

  bool get isMainIsolate => this == main;
}

enum IsolateStatus {
  busy,
  idle;

  bool get isIdle => this == idle;
}

class SyncRequestController<RESPONE, REQUEST> {
  final Stream<RESPONE> stream;
  final StreamController<REQUEST> controller;
  StreamSubscription<RESPONE>? subscription;

  SyncRequestController({required this.controller, required this.stream});
  void close() {
    subscription?.cancel();
    subscription = null;
    controller.close();
  }
}
