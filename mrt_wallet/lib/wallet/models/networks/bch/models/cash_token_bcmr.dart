import 'package:mrt_wallet/app/core.dart';

class CashTokenBCMR with Equatable {
  const CashTokenBCMR(
      {required this.uri, required this.hash, required this.content});
  final String uri;
  final String hash;
  final Map<String, dynamic> content;

  @override
  List get variabels => [hash, uri];
  CashTokenBCMR copyWith(
      {String? uri, String? hash, Map<String, dynamic>? content}) {
    return CashTokenBCMR(
        uri: uri ?? this.uri,
        hash: hash ?? this.hash,
        content: content ?? this.content);
  }
}
