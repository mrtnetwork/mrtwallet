part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

// ignore: library_private_types_in_public_api
mixin WalletsManager on _WalletCore {
  WalletController? _wallet;

  WalletController get _controller {
    if (_wallet == null) {
      throw WalletExceptionConst.walletIsNotavailable;
    }
    return _wallet!;
  }

  HDWallets _wallets = HDWallets.init();

  WalletStatus _homePageStatus = WalletStatus.setup;
  WalletStatus get homePageStatus => _homePageStatus;
  bool get isSetup => _homePageStatus.isSetup;
  bool get isOpen => homePageStatus.isReady && _controller.isOpen;
  bool get isLock => homePageStatus.isReady && _controller.isLock;
  bool get isUnlock => homePageStatus.isReady && _controller.isUnlock;
  bool get isReadOnly => homePageStatus.isReady && _controller.isReadOnly;

  Future<void> _initWallet({bool useIsolate = true}) async {
    crypto.init(useIsolate);
    if (_homePageStatus != WalletStatus.setup) {
      return;
    }
    _wallets = await _readWallet();
    await _initPage();
  }

  Future<void> _updateWallet(HDWallet wallet, {bool? asDefaultWallet}) async {
    _wallets.updateWallet(wallet, asDefaultWallet: asDefaultWallet);
    await _writeHdWallet(_wallets);
  }

  Future<void> _initPage({HDWallet? slectedWallet}) async {
    if (_wallets.hasWallet) {
      final wallet = _wallets.getInitializeWallet(name: slectedWallet?.name);
      final controller =
          await WalletController._setup(this as WalletCore, wallet);
      final currentController = _wallet;
      await currentController?._dispose();
      _wallet = controller;
      _homePageStatus = WalletStatus.ready;
    } else {
      _homePageStatus = WalletStatus.setup;
    }
  }

  Future<void> _setup(
      {required HDWallet hdWallet,
      required String password,
      required WalletUpdateInfosData walletInfos,
      List<Chain> chains = const []}) async {
    if (!StrUtils.isStrongPassword(password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final updatedWallet = HDWallet(
        checksum: hdWallet._checksum,
        name: walletInfos.name,
        data: hdWallet._data,
        requiredPassword: walletInfos.requirmentPassword,
        locktime: walletInfos.lockTime,
        network: 0,
        protectWallet: walletInfos.protectWallet);
    _wallets.validateImport(updatedWallet);
    final pw = await _toWalletPassword(password, updatedWallet._checksum);
    await crypto.cryptoRequest(CryptoRequestGenerateMasterKey.fromStorage(
        storageData: updatedWallet._data, key: pw));

    _wallets.setupWallet(updatedWallet, asDefault: walletInfos.asDefaultWallet);
    await _initializeWallet(updatedWallet, chains: chains);
    await _initPage(slectedWallet: updatedWallet);
    await _writeHdWallet(_wallets);
  }

  Future<void> _initializeWallet(HDWallet wallet,
      {List<Chain> chains = const []}) async {
    await _removeWalletStorage(wallet);
    await _setupWalletAccounts(chains, wallet);
  }

  Future<List<int>> _toWalletPassword(
      String password, String walletCheckSum) async {
    return await crypto.cryptoRequest(CryptoRequestWalletKey.fromString(
        key: password, checksum: walletCheckSum));
  }

  Future<bool> _switchWallet(HDWallet switchWallet) async {
    if (switchWallet.name == _controller._wallet.name) return false;
    await _initPage(slectedWallet: switchWallet);
    return true;
  }

  Future<void> _eraseWallet(String password) async {
    final controller = _controller;
    await controller._validatePassword(password);
    await controller._dispose();
    _wallets.removeWallet(controller._wallet);
    await _writeHdWallet(_wallets);
    await _removeWalletStorage(controller._wallet);
    await _initPage();
  }

  Future<T> cryptoRequest<T, A extends MessageArgs,
      E extends MessageArgsCompleter<T, A>>(E request) async {
    return crypto.cryptoRequest(request);
  }
}
