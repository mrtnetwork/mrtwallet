import 'dart:async';
import 'package:http/retry.dart' as r;
import 'package:http/http.dart' as http;
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';
import 'package:mrt_wallet/app/http/utils/digest_authenticated.dart';

class HttpClientManagerConst {
  static const Duration idleTimeout = Duration(minutes: 3);
  static const List<int> retryStatusCodes = [408, 500, 502, 503, 504];
}

typedef OnHTTPRequest = Future<http.Response> Function(
    {required r.RetryClient client,
    required Uri uri,
    required Map<String, String>? headers});

class HttpClientManager {
  final Map<String, _CachedClientImpl> _clients = {};
  final Duration idleTimeout;

  HttpClientManager({this.idleTimeout = HttpClientManagerConst.idleTimeout});
  http.Client getClient() {
    return http.Client();
  }

  Future<http.Response> call({
    required OnHTTPRequest t,
    required Uri uri,
    required HTTPClientType clientType,
    required HTTPRequestType method,
    ProviderAuthenticated? authenticated,
    Map<String, String>? headers,
  }) async {
    final client = getCashedClient(
        uri: uri, client: clientType, authenticated: authenticated);
    try {
      final r = await t(
          client: client.client,
          headers: client.toHeaders(method: method, uri: uri, headers: headers),
          uri: client.toUri(uri));
      return await client.call(
          response: r,
          onRetry: ({required client, required headers, required uri}) =>
              t(client: client, headers: headers, uri: uri),
          method: method,
          uri: uri,
          headers: headers);
    } finally {
      if (clientType == HTTPClientType.single) {
        client.dispose();
      }
    }
  }

  // ignore: library_private_types_in_public_api
  _Client getCashedClient(
      {required Uri uri,
      required HTTPClientType client,
      ProviderAuthenticated? authenticated}) {
    if (client == HTTPClientType.single) {
      final inner = r.RetryClient(http.Client());
      if (authenticated?.type == ProviderAuthType.digest) {
        return _DigestAuthClient(
            authenticated: authenticated as DigestProviderAuthenticated,
            client: inner);
      }
      return _Client(client: inner, authenticated: authenticated);
    }
    try {
      final identifier = "${uri.host}_${authenticated.hashCode}";
      if (_clients.containsKey(identifier)) {
        final cachedClient = _clients[identifier]!;
        cachedClient.resetTimer();
        return cachedClient;
      }

      final newClient = r.RetryClient(
        http.Client(),
        when: (response) {
          return HttpClientManagerConst.retryStatusCodes
              .contains(response.statusCode);
        },
      );
      final _CachedClientImpl client;
      if (authenticated?.type == ProviderAuthType.digest) {
        client = _DigestAuthCachedClient(
            client: newClient,
            onDispose: () => _clients.remove(identifier),
            idleTimeout: idleTimeout,
            authenticated: authenticated as DigestProviderAuthenticated);
      } else {
        client = _CachedClient(
            client: newClient,
            onDispose: () => _clients.remove(identifier),
            idleTimeout: idleTimeout,
            authenticated: authenticated);
      }
      _clients[identifier] = client;
      return client;
    } finally {}
  }

  void closeAll() {
    for (final cachedClient in _clients.values) {
      cachedClient.dispose();
    }
    _clients.clear();
  }
}

class _Client<T extends ProviderAuthenticated?> {
  final r.RetryClient client;
  final T authenticated;
  const _Client({required this.client, required this.authenticated});

  Uri toUri(Uri uri) {
    return authenticated?.toUri(uri) ?? uri;
  }

  Map<String, String>? toHeaders({
    required HTTPRequestType method,
    required Uri uri,
    List<int>? body,
    required Map<String, String>? headers,
  }) {
    return authenticated?.toHeaders(headers) ?? headers;
  }

  Future<http.Response> call(
      {required http.Response response,
      required OnHTTPRequest onRetry,
      required HTTPRequestType method,
      required Uri uri,
      required Map<String, String>? headers}) async {
    return response;
  }

  void dispose() {
    client.close();
  }
}

abstract class _CachedClientImpl<T extends ProviderAuthenticated?>
    extends _Client<T> {
  final DynamicVoid onDispose;
  final Duration idleTimeout;
  Timer? _timer;
  _CachedClientImpl(
      {required this.onDispose,
      required this.idleTimeout,
      required super.client,
      required super.authenticated}) {
    _startTimer();
  }
  void resetTimer() {
    _timer?.cancel();
    _startTimer();
  }

  void stopTime() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _timer = Timer(idleTimeout, () {
      client.close();
      onDispose();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    client.close();
  }
}

class _CachedClient extends _CachedClientImpl {
  _CachedClient(
      {required super.client,
      required super.onDispose,
      required super.idleTimeout,
      super.authenticated});
}

class _DigestAuthClient extends _Client<DigestProviderAuthenticated>
    with _DigestAuthClientImpl {
  _DigestAuthClient({required super.client, required super.authenticated});
}

class _DigestAuthCachedClient
    extends _CachedClientImpl<DigestProviderAuthenticated>
    with _DigestAuthClientImpl {
  _DigestAuthCachedClient(
      {required super.client,
      required super.onDispose,
      required super.idleTimeout,
      required super.authenticated});
}

mixin _DigestAuthClientImpl on _Client<DigestProviderAuthenticated> {
  @override
  DigestProviderAuthenticated get authenticated;
  int _id = 1;

  DigestAuthHeaders? _challenge;

  @override
  Map<String, String>? toHeaders(
      {required HTTPRequestType method,
      required Uri uri,
      List<int>? body,
      required Map<String, String>? headers}) {
    if (_challenge != null) {
      final h = DigestAuthenticatedUtils.getDigestAuthenticatedHeader(
          authenticated: authenticated,
          params: _challenge!,
          method: method,
          uri: uri,
          count: _id);
      _id++;
      return {...h, ...headers ?? {}};
    }
    return super
        .toHeaders(method: method, uri: uri, body: body, headers: headers);
  }

  @override
  Future<http.Response> call(
      {required http.Response response,
      required OnHTTPRequest onRetry,
      required HTTPRequestType method,
      required Uri uri,
      required Map<String, String>? headers}) async {
    switch (response.statusCode) {
      case DigestAuthenticatedUtils.digestRetrAutheticatedStatusCode:
        _challenge = DigestAuthenticatedUtils.getChallenges(response.headers);
        if (_challenge != null) {
          _id = 1;
          final updateHeaders =
              toHeaders(method: method, uri: uri, headers: headers);
          return onRetry(client: client, headers: updateHeaders, uri: uri);
        }
        break;
      default:
    }
    return super.call(
        response: response,
        onRetry: onRetry,
        method: method,
        uri: uri,
        headers: headers);
  }
}
