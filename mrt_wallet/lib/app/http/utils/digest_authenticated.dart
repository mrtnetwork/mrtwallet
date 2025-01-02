import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';

class DigestAuthenticatedUtils {
  static const int digestRetrAutheticatedStatusCode = 401;
  static const String digestAuthKey = "www-authenticate";
  static const String digestKey = "Digest ";
  static const String autorizationKey = "Authorization";

  static bool canUseAuthDigest(Map<String, String> headers) {
    return (headers[digestAuthKey]?.contains(digestKey) ?? false);
  }

  /// Generate Digest Authentication header
  static String generateDigestAuthHeader({
    required DigestProviderAuthenticated authenticated,
    required HTTPRequestType method,
    required Uri uri,
    List<int>? body,
    int count = 1,
    required DigestAuthHeaders params,
  }) {
    final realm = params.realm;
    final nonce = params.nonce;
    final qop = params.qop;
    final algorithm = params.algorithm;
    final path = uri.path;
    final cnonce = BytesUtils.toHexString(QuickCrypto.generateRandom(8));
    final nc = count.toRadixString(16).padLeft(8, '0');
    String ha1 = algorithm.hashString(
        '${authenticated.username}:$realm:${authenticated.password}');
    if (algorithm.sessionBased) {
      ha1 = algorithm.hashString('$ha1:$nonce:$cnonce');
    }
    final String ha2 = switch (qop) {
      DigestAuthQop.auth ||
      null =>
        algorithm.hashString('${method.name}:$path'),
      DigestAuthQop.authInt => algorithm
          .hashString('${method.name}:$uri:${algorithm.hashBytes(body ?? [])}'),
    };

    final response = switch (qop) {
      DigestAuthQop.auth ||
      DigestAuthQop.authInt =>
        algorithm.hashString('$ha1:$nonce:$nc:$cnonce:${qop!.name}:$ha2'),
      null => algorithm.hashString('$ha1:$nonce:$ha2'),
    };
    String digest =
        'Digest username="${authenticated.username}", realm="$realm", nonce="$nonce", uri="$path", '
        'nc=$nc, cnonce="$cnonce", response="$response", algorithm=${algorithm.name}';
    if (qop != null) {
      digest += ', qop=${qop.name}';
    }
    if (params.opaque != null) {
      digest += ', opaque=${params.opaque}';
    }
    return digest;
  }

  static DigestAuthHeaders? getChallenges(Map<String, String> headers) {
    if (!canUseAuthDigest(headers)) return null;
    final challenges = parseDigestHeader(headers[digestAuthKey]!);
    if (challenges.isEmpty) throw WalletException("unsuported_digest_auth_qop");
    return challenges.first;
  }

  static Map<String, dynamic> getDigestAuthenticatedHeader(
      {required DigestProviderAuthenticated authenticated,
      required DigestAuthHeaders params,
      required HTTPRequestType method,
      required Uri uri,
      required int count,
      List<int>? body}) {
    return {
      autorizationKey: generateDigestAuthHeader(
          authenticated: authenticated,
          method: method,
          uri: uri,
          params: params,
          body: body,
          count: count)
    };
  }

  static List<DigestAuthHeaders> parseDigestHeader(String header) {
    if (!header.contains(digestKey)) {
      throw WalletException("invalid_dgiest_auth_headers");
    }
    final digestParts = header
        .split('Digest ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != ",")
        .toList();

    final List<DigestAuthHeaders> auth = [];
    for (final i in digestParts) {
      final challenge = i.split(',').map((e) => e.trim()).toList();
      final Map<String, dynamic> params = {};
      for (final part in challenge) {
        final match = RegExp(r'^(.*?)=(.*)$').firstMatch(part);
        if (match != null) {
          final key = match.group(1)!.trim();
          final value = match.group(2)!.replaceAll('"', '').trim();
          params[key] = value;
        }
      }
      try {
        final digestParams = DigestAuthHeaders.fromJson(params);
        auth.add(digestParams);
      } on WalletException catch (_) {}
    }

    return auth;
  }
}
