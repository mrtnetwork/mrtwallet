part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

// ignore: library_private_types_in_public_api
mixin WalletManager on _WalletCore {
  late WalletController _controller;
  HDWallets _wallets = HDWallets.init();

  final _crypto = IsolateCryptoWoker();

  WalletStatus _homePageStatus = WalletStatus.setup;
  WalletStatus get homePageStatus => _homePageStatus;

  bool get isOpen => homePageStatus.isReady && _controller.isOpen;
  bool get _isUnlock => homePageStatus.isReady && _controller.isUnlock;
  bool get _isLock => homePageStatus.isReady && _controller.isLock;
  bool get _isReadOnly => homePageStatus.isReady && _controller.isReadOnly;

  Future<void> _initWallet() async {
    _wallets = await _readWallet();
    await _initPage();
  }

  Future<void> _updateWallet(HDWallet wallet, bool? asDefaultWallet) async {
    _wallets.updateWallet(wallet, asDefaultWallet: asDefaultWallet);
    await _writeHdWallet(_wallets);
  }

  Future<void> _initPage({HDWallet? slectedWallet}) async {
    if (_wallets.hasWallet) {
      final wallet = _wallets.getInitializeWallet(name: slectedWallet?.name);
      final controller = await WalletController._setup(wallet, _updateWallet);
      if (_homePageStatus.isReady) {
        /// clean up wallet
        final currentController = _controller;
        await currentController._dispose();
      }
      _controller = controller;
      _homePageStatus = WalletStatus.ready;
    } else {
      _homePageStatus = WalletStatus.setup;
    }
  }

  Future<void> _setup(
      {required HDWallet hdWallet,
      required String password,
      required WalletUpdateInfosData walletInfos,
      List<ChainHandler> chains = const []}) async {
    if (!StrUtils.isStrongPassword(password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final updatedWallet = HDWallet(
        checksum: hdWallet._checksum,
        name: walletInfos.name,
        data: hdWallet._data,
        requiredPassword: walletInfos.requirmentPassword,
        locktime: walletInfos.lockTime,
        network: 0);
    _wallets.validateImport(updatedWallet);
    final pw = _toWalletPassword(
        password, BytesUtils.fromHexString(updatedWallet._checksum));
    await _crypto.generateMasterKey(updatedWallet._data, pw);
    _wallets.setupWallet(updatedWallet, asDefault: walletInfos.asDefaultWallet);
    await _initializeWallet(updatedWallet, chains: chains);
    await _initPage(slectedWallet: updatedWallet);
    await _writeHdWallet(_wallets);
  }

  Future<void> _initializeWallet(HDWallet wallet,
      {List<ChainHandler> chains = const []}) async {
    await _removeWalletStorage(wallet);
    await _setupWalletAccounts(chains, wallet);
  }

  List<int> _validatePassword(String password) {
    return _controller._validatePassword(password);
  }

  List<int> _toWalletPassword(String password, List<int> walletCheckSum) {
    final List<int> key = SHA3
        .hash(List.from([...StringUtils.encode(password), ...walletCheckSum]));
    return List<int>.unmodifiable(
        key.sublist(0, WalletProviderConst.encryptionKeyLength));
  }

  Future<void> _switchWallet(HDWallet switchWallet) async {
    if (switchWallet.name == _controller._wallet.name) return;
    await _initPage(slectedWallet: switchWallet);
  }

  Future<void> _eraseWallet(String password) async {
    final controller = _controller;
    controller._validatePassword(password);
    await controller._dispose();
    _wallets.removeWallet(controller._wallet);
    await _writeHdWallet(_wallets);
    await _removeWalletStorage(controller._wallet);
    await _initPage();
  }
}
