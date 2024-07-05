import 'package:blockchain_utils/utils/binary/utils.dart';

class WorkerMessageConst {
  static const List<int> encryptChaha = [100, 5, 1, 1];
  static const List<int> decryptChacha = [100, 5, 1, 2];
  static const List<int> generateMemoryStorage = [99, 0, 0, 1];
  static const List<int> readMasterKeyFromMemoryStorage = [98, 0, 0, 1];
  static const List<int> generateMasterKey = [97, 0, 0, 1];
  static const List<int> readMasterKey = [96, 0, 0, 1];
  static const List<int> restoreBackup = [95, 0, 0, 2];
  static const List<int> createBackup = [95, 0, 0, 1];
  static const List<int> createWalletSeed = [94, 0, 0, 1];
  static const List<int> workerMessagRequest = [1, 12, 3, 13];
  static const List<int> workerMessagResponse = [2, 24, 4, 26];
  static const List<int> encryptedMessage = [0, 1, 2, 3];
  static const List<int> setup = [101, 0, 0, 1];
  static const List<int> importNewKey = [101, 0, 0, 5];
  static const List<int> removeKey = [101, 0, 0, 6];
  static const List<int> changePassword = [101, 0, 0, 7];
  static const List<int> updateSettings = [101, 0, 0, 8];
  static const List<int> readImportKey = [101, 0, 0, 9];
  static const List<int> readPrivateKeys = [101, 0, 0, 10];
  static const List<int> readPrivateKey = [101, 0, 0, 11];
  static const List<int> readMnemonic = [101, 0, 0, 12];
  static const List<int> readPublicKey = [101, 0, 0, 13];
  static const List<int> readPublicKeys = [101, 0, 0, 14];
  static const List<int> sign = [103, 0, 0, 0];
}

enum CryptoMessageType {
  decryptChacha(WorkerMessageConst.decryptChacha),
  encryptChacha(WorkerMessageConst.encryptChaha),
  generateMasterKey(WorkerMessageConst.generateMasterKey),
  generateMemoryStorage(WorkerMessageConst.generateMemoryStorage),
  readMasterKey(WorkerMessageConst.readMasterKey),
  restoreBackup(WorkerMessageConst.restoreBackup),
  createBackup(WorkerMessageConst.createBackup),
  createWalletSeed(WorkerMessageConst.createWalletSeed),
  importNewKey(WorkerMessageConst.importNewKey),
  removeKey(WorkerMessageConst.removeKey),
  changePassword(WorkerMessageConst.changePassword),
  setup(WorkerMessageConst.setup),
  readImportKey(WorkerMessageConst.readImportKey),
  readPrivateKeys(WorkerMessageConst.readPrivateKeys),
  readPrivateKey(WorkerMessageConst.readPrivateKey),
  readPublicKey(WorkerMessageConst.readPublicKey),
  readPublicKeys(WorkerMessageConst.readPublicKeys),
  readMnemonic(WorkerMessageConst.readMnemonic),
  sign(WorkerMessageConst.sign),
  readMasterKeyFromMemoryStorage(
      WorkerMessageConst.readMasterKeyFromMemoryStorage);

  final List<int> tag;
  const CryptoMessageType(this.tag);
  static CryptoMessageType fromTag(List<int> tag) {
    return values
        .firstWhere((element) => BytesUtils.bytesEqual(tag, element.tag));
  }
}
