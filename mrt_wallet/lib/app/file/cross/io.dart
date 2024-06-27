import 'dart:io';

import 'package:blockchain_utils/crypto/crypto/crc32/crc32.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/native_impl/io/path_provider.dart';

Future<String> writeTOFile(String data, String fileName,
    {bool validate = true}) async {
  final dir = await PathProvider.toCacheDir(fileName);
  final decode = StringUtils.encode(data);
  final checksum = Crc32.quickIntDigest(decode);
  final File file = File(dir);
  if (await file.exists()) {
    await file.delete();
  }
  final created = await file.create(recursive: true);
  await created.writeAsBytes(decode);
  if (validate) {
    await _validate(created.path, checksum);
  }
  return created.path;
}

Future<String> bytesToFile(
    {required List<int> bytes,
    required String fileName,
    bool validate = true}) async {
  final dir = await PathProvider.toCacheDir(fileName);
  final File barcodeFile =
      await File(dir).create(recursive: true).then((File file) async {
    await file.writeAsBytes(bytes);
    return file;
  });
  return barcodeFile.path;
}

Future<void> _validate(String path, int checksum) async {
  final fileBytes = await File(path).readAsBytes();
  final currentChecksum = Crc32.quickIntDigest(fileBytes);
  if (currentChecksum != checksum) {
    throw WalletExceptionConst.fileVerificationFiled;
  }
}
