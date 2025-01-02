part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class ChainStorageManagerUtils {
  static String buildStorageId(int networkId, String walletid) {
    return "${StorageConst.walletStorageKey}${walletid}_${networkId.toString()}";
  }

  static String buildChainStorageId(int networkId, String walletid) {
    return "${StorageConst.chainSorageKey}${walletid}_${networkId.toString()}_";
  }

  static String buildChainStorageStorageId(String chainStorageId, int storageId,
      {String? suffix}) {
    return "$chainStorageId${storageId}_${suffix ?? ''}";
  }

  static (int, String?) cleanUpChainStorageKey(
      {required String key,
      required String chainStorageId,
      required int networkId}) {
    assert(key.startsWith(chainStorageId), "invalid chain storage key");
    final withoutChain = key.replaceFirst(chainStorageId, '');
    final parts = withoutChain.split('_');
    final int storageId = int.parse(parts[0]);
    final String? prefix = parts[1].isEmpty ? null : parts[1];
    return (storageId, prefix);
  }

  static (int, String) toStorageKey(
      {required String key,
      required String chainStorageId,
      required int networkId}) {
    try {
      final parts = key.split("#");
      final id = IntUtils.parse(parts[0]);
      final index = parts[1].indexOf("_");
      final storageIdPart = IntUtils.parse(parts[1].substring(0, index));
      if (id == networkId) {
        return (storageIdPart, parts[1].substring(index));
      }
    } catch (_) {}
    throw WalletExceptionConst.invalidData(
        messsage: "Invalid chain repository item.");
    // return (storageP);
  }
}

mixin ChainStorageManager<
    NETWORK extends WalletNetwork,
    STORAGE extends ChainStorageKey,
    CONFIG extends ChainConfig<STORAGE>> on CborSerializable {
  CONFIG get config;
  NETWORK get network;
  String get id;
  late final String storageId =
      ChainStorageManagerUtils.buildStorageId(network.value, id);
  late final String chainStorageId =
      ChainStorageManagerUtils.buildChainStorageId(network.value, id);

  String _buildStorageKey(ChainStorageKey storage, {String? suffix}) {
    return ChainStorageManagerUtils.buildChainStorageStorageId(
        chainStorageId, storage.storageId,
        suffix: suffix);
  }

  Future<String?> _readStorage(
      {required ChainStorageKey storage, String? identifier}) async {
    final String key = _buildStorageKey(storage, suffix: identifier);
    return await AppNativeMethods.platform.readSecure(key);
  }

  Future<List<MRTWalletBackupChainRepository>> _readAllRepositories() async {
    final keys =
        await AppNativeMethods.platform.readAllSecure(prefix: chainStorageId);
    return keys.keys.map((e) {
      final storageKey = ChainStorageManagerUtils.cleanUpChainStorageKey(
          key: e, chainStorageId: chainStorageId, networkId: network.value);
      return MRTWalletBackupChainRepository(
          identifier: storageKey.$2,
          storageID: storageKey.$1,
          value: keys[e]!,
          networkID: network.value);
    }).toList();
  }

  Future<void> restoreChainRepositories(
      List<MRTWalletBackupChainRepository> repositories) async {
    for (final i in repositories) {
      if (i.networkID != network.value) {
        throw WalletExceptionConst.invalidData(
            messsage: "invalid repository data.");
      }
      final storageKey = config.storageKeys.firstWhere(
          (e) => e.storageId == i.storageID,
          orElse: () => throw WalletExceptionConst.invalidData(
              messsage: "invalid repository data."));
      await _write(
          storage: storageKey, item: i.value, identifier: i.identifier);
    }
  }

  Future<void> _write(
      {required ChainStorageKey storage,
      required String? item,
      String? identifier}) async {
    final String key = _buildStorageKey(storage, suffix: identifier);
    if (item == null) {
      return _removeStorage(storage: storage, identifier: identifier);
    }
    await AppNativeMethods.platform.writeSecure(key, item);
  }

  Future<void> _writeStorageItem(
      {required ChainStorageKey storage,
      required CborSerializable? item,
      String? identifier}) async {
    await _write(
        storage: storage,
        item: item?.toCbor().toCborHex(),
        identifier: identifier);
  }

  Future<void> _save() async {
    await AppNativeMethods.platform
        .writeSecure(storageId, toCbor().toCborHex());
  }

  Future<void> _removeStorage(
      {required ChainStorageKey storage, String? identifier}) async {
    final String key = _buildStorageKey(storage, suffix: identifier);
    await AppNativeMethods.platform.removeSecure(key);
  }
}
