part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

class HDWalletsConst {
  static const String initializeName = "Wallet";
  static const String firstWalletName = "$initializeName (1)";
}

class HDWallets with CborSerializable {
  Map<String, HDWallet> _wallets;
  String? _defaultWallet;
  String? get defaultWallet => _defaultWallet;
  bool get hasWallet => _wallets.isNotEmpty;
  bool get needSetup => _wallets.isEmpty;

  List<String> get walletNames => _wallets.keys.toList();

  factory HDWallets.init() => HDWallets._(wallets: {}, defaultWallet: null);

  factory HDWallets.legacy(
          {required String checksum, required String data, int? network}) =>
      HDWallets._(wallets: {
        HDWalletsConst.firstWalletName: HDWallet(
            checksum: checksum,
            name: HDWalletsConst.firstWalletName,
            requiredPassword: true,
            data: data,
            network: network ?? 0,
            locktime: WalletLockTime.fiveMinute,
            created: DateTime.now())
      }, defaultWallet: HDWalletsConst.firstWalletName);

  HDWallets._(
      {required Map<String, HDWallet> wallets, required String? defaultWallet})
      : _wallets = Map<String, HDWallet>.unmodifiable(wallets),
        _defaultWallet = defaultWallet;
  factory HDWallets.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.wallets);
    final wallets = cbor
        .elementAt<List<dynamic>>(0)
        .map((e) => HDWallet.fromCborBytesOrObject(obj: e));
    return HDWallets._(
        wallets: Map<String, HDWallet>.fromEntries(
            wallets.map((e) => MapEntry<String, HDWallet>(e.name, e))),
        defaultWallet: cbor.elementAt(1));
  }

  HDWallet getInitializeWallet({String? name}) {
    if (_wallets.isEmpty) {
      throw WalletExceptionConst.incompleteWalletSetup;
    }
    if (_wallets.containsKey(name ?? defaultWallet)) {
      return _wallets[name ?? defaultWallet]!;
    }
    return _wallets.values.first;
  }

  HDWallet getWallet(String name) {
    if (_wallets.containsKey(name)) {
      return _wallets[name]!;
    }
    throw WalletExceptionConst.walletDoesNotExists;
  }

  void removeWallet(HDWallet wallet) {
    if (_wallets.containsKey(wallet.name)) {
      final wallets = Map<String, HDWallet>.from(_wallets);
      wallets.remove(wallet.name);
      _wallets = Map<String, HDWallet>.unmodifiable(wallets);
      return;
    }
    throw WalletExceptionConst.walletDoesNotExists;
  }

  void updateWallet(HDWallet wallet, {bool? asDefaultWallet}) {
    final current = _wallets.values.firstWhere(
        (element) => element._checksum == wallet._checksum,
        orElse: () => throw WalletExceptionConst.walletDoesNotExists);
    if (wallet.name != current.name && _wallets.containsKey(wallet.name)) {
      throw WalletExceptionConst.walletNameExists;
    }

    final wallets = Map<String, HDWallet>.from(_wallets);
    wallets.remove(current.name);
    wallets.addAll({wallet.name: wallet});
    _wallets = Map<String, HDWallet>.unmodifiable(wallets);
    if (asDefaultWallet != null) {
      if (asDefaultWallet) {
        _defaultWallet = wallet.name;
      } else if (_defaultWallet == current.name) {
        _defaultWallet = null;
      }
    }
  }

  void validateImport(HDWallet newWallet) {
    if (_wallets.containsKey(newWallet.name) ||
        _wallets.values
            .any((element) => element._checksum == newWallet._checksum)) {
      throw WalletExceptionConst.walletAlreadyExists;
    }
  }

  void setupWallet(HDWallet newWallet, {bool asDefault = false}) {
    if (_wallets.containsKey(newWallet.name) ||
        _wallets.values
            .any((element) => element._checksum == newWallet._checksum)) {
      throw WalletExceptionConst.walletAlreadyExists;
    }

    final updateWallet = newWallet._updateCreated();
    final wallets = Map<String, HDWallet>.from(_wallets);
    wallets.addAll({updateWallet.name: updateWallet});
    _wallets = Map<String, HDWallet>.unmodifiable(wallets);
    if (asDefault || !_wallets.containsKey(defaultWallet)) {
      _defaultWallet = updateWallet.name;
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              _wallets.values.map((e) => e._toCbor()).toList()),
          defaultWallet ?? const CborNullValue()
        ]),
        CborTagsConst.wallets);
  }
}

class HDWallet {
  final String _checksum;
  final String name;
  final String _data;
  final bool requiredPassword;
  final bool protectWallet;
  final WalletLockTime locktime;
  final int network;
  final DateTime created;

  HDWallet._(
      {required String checksum,
      required this.name,
      required String data,
      required this.requiredPassword,
      required this.locktime,
      required this.network,
      required this.created,
      required this.protectWallet})
      : _data = data,
        _checksum = checksum;
  factory HDWallet({
    required String checksum,
    required String name,
    required String data,
    required bool requiredPassword,
    required WalletLockTime locktime,
    required int network,
    bool protectWallet = true,
    DateTime? created,
  }) {
    if (name.trim().isEmpty || name.length < 3 || name.length > 15) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    final lockTime = locktime.value ~/ 60;
    if (lockTime < 1 || lockTime > 30) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return HDWallet._(
        checksum: checksum,
        name: name,
        data: data,
        requiredPassword: requiredPassword,
        locktime: locktime,
        network: network,
        created: created ?? DateTime.now(),
        protectWallet: protectWallet);
  }

  factory HDWallet.setup(
      {required String checksum,
      required String name,
      required String data,
      bool protectWallet = true}) {
    return HDWallet(
        checksum: checksum,
        name: name,
        data: data,
        requiredPassword: false,
        locktime: WalletLockTime.fiveMinute,
        network: 0,
        created: DateTime.now(),
        protectWallet: protectWallet);
  }
  HDWallet _updateData(String updateData) {
    return HDWallet(
        checksum: _checksum,
        name: name,
        data: updateData,
        requiredPassword: requiredPassword,
        network: network,
        locktime: locktime,
        created: created,
        protectWallet: protectWallet);
  }

  HDWallet updateNetwork(int updateNetworkId) {
    return HDWallet(
        checksum: _checksum,
        name: name,
        data: _data,
        requiredPassword: requiredPassword,
        network: updateNetworkId,
        locktime: locktime,
        created: created,
        protectWallet: protectWallet);
  }

  HDWallet _updateCreated() {
    return HDWallet(
        checksum: _checksum,
        name: name,
        data: _data,
        requiredPassword: requiredPassword,
        network: network,
        locktime: locktime,
        created: DateTime.now(),
        protectWallet: protectWallet);
  }

  HDWallet _updateSettings({
    required WalletLockTime newLockTime,
    required bool reqPassword,
    required String newName,
    required bool protectWallet,
  }) {
    if (newName.trim().isEmpty || newName.length < 3 || newName.length > 15) {
      throw WalletExceptionConst.dataVerificationFailed;
    }

    return HDWallet(
        checksum: _checksum,
        name: newName,
        data: _data,
        requiredPassword: reqPassword,
        network: network,
        locktime: newLockTime,
        created: created,
        protectWallet: protectWallet);
  }

  factory HDWallet.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.wallet);
    final int? setting = cbor.elementAt(5);
    final network = cbor.elementAt<int>(4);
    WalletLockTime lockTime = WalletLockTime.fiveMinute;
    if (setting != null) {
      lockTime = WalletLockTime.fromValue(setting);
    }
    return HDWallet(
        checksum: cbor.elementAt(0),
        name: cbor.elementAt(1),
        data: cbor.elementAt(2),
        requiredPassword: cbor.elementAt(3),
        network: network,
        locktime: lockTime,
        created: cbor.elementAt<DateTime>(6),
        protectWallet: cbor.elementAt<bool?>(7) ?? true);
  }

  CborTagValue _toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          _checksum,
          name,
          _data,
          CborBoleanValue(requiredPassword),
          network,
          locktime.value,
          CborEpochIntValue(created),
          protectWallet
        ]),
        CborTagsConst.wallet);
  }

  List<int> get checkSumBytes => BytesUtils.fromHexString(_checksum);
  String get _networkKey => "${StorageConst.walletStorageKey}${_checksum}_";
  String get _permissionKey =>
      "${StorageConst.walletStorageKey}$_checksum#permission_";

  String _toPermissionKey(String key) {
    return "$_permissionKey$key";
  }
}
