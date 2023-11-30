part of 'package:mrt_native_support/web/mrt_native_web.dart';

const String storageKey = 'SAFESTORAGE';

crypto.SubtleAlgorithm toSubtleAlgo(Uint8List iv) =>
    crypto.SubtleAlgorithm(iv: iv);

Future<html.CryptoKey> getEncryptionKey(
    crypto.SubtleAlgorithm algorithm) async {
  late html.CryptoKey encryptionKey;

  if (html.window.localStorage.containsKey(storageKey)) {
    final jwk = base64Decode(html.window.localStorage[storageKey]!);
    encryptionKey = await js_util.promiseToFuture<html.CryptoKey>(
      crypto.importKey("raw", jwk, algorithm, false, ["encrypt", "decrypt"]),
    );
  } else {
    encryptionKey = await js_util.promiseToFuture<html.CryptoKey>(
      crypto.generateKey(algorithm, true, ["encrypt", "decrypt"]),
    );

    final jsonWebKey = await js_util
        .promiseToFuture<ByteBuffer>(crypto.exportKey("raw", encryptionKey));
    html.window.localStorage[storageKey] =
        base64Encode(jsonWebKey.asUint8List());
  }

  return encryptionKey;
}

Future<String?> decryptValue(String? cypherText) async {
  if (cypherText == null) {
    return null;
  }

  final parts = cypherText.split(".");

  final iv = base64Decode(parts[0]);
  final algorithm = toSubtleAlgo(iv);

  final decryptionKey = await getEncryptionKey(algorithm);

  final value = base64Decode(parts[1]);

  final decryptedContent = await js_util.promiseToFuture<ByteBuffer>(
    crypto.decrypt(
      toSubtleAlgo(iv),
      decryptionKey,
      Uint8List.fromList(value),
    ),
  );

  final plainText = utf8.decode(decryptedContent.asUint8List());

  return plainText;
}

Future<ByteBuffer> encrypt(crypto.SubtleAlgorithm algorithm,
    html.CryptoKey encryptionKey, String value) async {
  final v = await js_util.promiseToFuture<ByteBuffer>(
    crypto.encrypt(
      algorithm,
      encryptionKey,
      Uint8List.fromList(
        utf8.encode(value),
      ),
    ),
  );
  return v;
}
