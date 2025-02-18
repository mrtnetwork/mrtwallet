part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

abstract class _WalletController with CryptoWokerImpl {
  _WalletController(this._walletCore, this._wallet, this._appChains);

  /// base wallet
  WalletCore? _walletCore;
  WalletCore get _core {
    if (_walletCore == null) {
      throw WalletExceptionConst.walletIsNotavailable;
    }
    return _walletCore!;
  }

  /// wallet key
  List<int>? _walletKey;

  /// wallet encryption data
  EncryptedMasterKey? _massterKey;

  /// wallet information like name, settings and etc.
  HDWallet _wallet;

  /// wallet networks controller.
  final ChainsHandler _appChains;

  /// current wallet account
  Chain get chain => _appChains.chain;

  /// current wallet network
  WalletNetwork get network => chain.network;

  /// current wallet status
  late HDWalletStatus _status =
      _wallet.requiredPassword ? HDWalletStatus.lock : HDWalletStatus.readOnly;

  /// wallet is locked
  bool get isLock => _status == HDWalletStatus.lock;

  /// wallet is read only
  bool get isReadOnly => _status == HDWalletStatus.readOnly;

  /// wallet unlocked.
  bool get isUnlock => _status == HDWalletStatus.unlock;

  /// wallet is read or unlocked.
  bool get isOpen => _status.isOpen;

  /// update wallet storage.
  Future<void> _updateWallet(HDWallet wallet, {bool? asDefaultWallet}) async {
    if (wallet._checksum != _wallet._checksum) return;
    _wallet = wallet;
    await _core._updateWallet(_wallet, asDefaultWallet: asDefaultWallet);
  }
}

class WalletController extends _WalletController
    with WalletManager, Web3Impl, WalletMoneroImpl {
  WalletController._(WalletCore super.core, super.wallet, super.chains);

  /// setup wallet.
  /// retrive wallet storage and init wallet controller.
  static Future<(ChainsHandler, List<String>)> _setupNetwork(
      WalletCore core, HDWallet wallet) async {
    final List<Chain> chains = [];
    final keys = await core._readAccounts(wallet);
    final keyBytes = keys.map((e) => e.$2).toList();
    List<String> junkKeys = [];
    for (final i in keyBytes) {
      try {
        final chain = Chain.deserialize(hex: i);
        chains.add(chain);
      } catch (_) {
        junkKeys.add(i);
      }
    }
    final chain = ChainsHandler(
        chains: chains, currentNetwork: wallet.network, id: wallet._checksum);

    return (chain, junkKeys);
  }

  /// setup wallet.
  static Future<WalletController> _setup(
      WalletCore core, HDWallet wallet) async {
    final handler = await _setupNetwork(core, wallet);
    final storageVersion = await core._readStorageVersion();
    if (storageVersion != core.storageVersion) {
      await core._writeStorageVersion(core.storageVersion);
      await core._deleteMultiple(keys: handler.$2);
      final chains = handler.$1.chains();
      for (final i in chains) {
        await i.save();
      }
    }
    final controller = WalletController._(core, wallet, handler.$1);

    await controller._onInitController();
    return controller;
  }

  /// dispose wallet.
  @override
  void _dispose() {
    _walletCore = null;
    _walletKey = null;
    _massterKey = null;
    _timeout.dispose();
    chain.disposeProvider();
    super._dispose();
  }
}
