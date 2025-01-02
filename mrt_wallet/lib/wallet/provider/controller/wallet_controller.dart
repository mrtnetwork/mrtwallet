part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

abstract class _WalletController with CryptoWokerImpl {
  _WalletController(this._walletCore, this._wallet, this._appChains);

  WalletCore? _walletCore;
  WalletCore get _core {
    if (_walletCore == null) {
      throw WalletExceptionConst.walletIsNotavailable;
    }
    return _walletCore!;
  }

  List<int>? _walletKey;
  EncryptedMasterKey? _massterKey;

  HDWallet _wallet;
  final ChainsHandler _appChains;
  Chain get chain => _appChains.chain;
  WalletNetwork get network => chain.network;

  late HDWalletStatus _status =
      _wallet.requiredPassword ? HDWalletStatus.lock : HDWalletStatus.readOnly;
  bool get isLock => _status == HDWalletStatus.lock;
  bool get isReadOnly => _status == HDWalletStatus.readOnly;
  bool get isUnlock => _status == HDWalletStatus.unlock;
  bool get isOpen => _status.isOpen;

  Future<void> _updateWallet(HDWallet wallet, {bool? asDefaultWallet}) async {
    if (wallet._checksum != _wallet._checksum) return;
    _wallet = wallet;
    await _core._updateWallet(_wallet, asDefaultWallet: asDefaultWallet);
  }
}

class WalletController extends _WalletController
    with
        WalletManager,
        Web3SolanaImpl,
        Web3EthereumImpl,
        Web3TronImpl,
        Web3TonImpl,
        Web3StellarImpl,
        Web3Impl,
        WalletMoneroImpl {
  WalletController._(WalletCore super.core, super.wallet, super.chains);
  static Future<ChainsHandler> _setupNetwork(
      WalletCore core, HDWallet wallet) async {
    final List<Chain> chains = [];
    final keys = await core._readAccounts(wallet);
    final keyBytes = keys.map((e) => BytesUtils.fromHexString(e.$2)).toList();
    for (final i in keyBytes) {
      try {
        final chain = Chain.deserialize(bytes: i);
        chains.add(chain);
      } catch (_) {}
    }
    final chain = ChainsHandler(
        chains: chains, currentNetwork: wallet.network, id: wallet._checksum);
    return chain;
  }

  static Future<WalletController> _setup(
      WalletCore core, HDWallet wallet) async {
    final chains = await _setupNetwork(core, wallet);
    final controller = WalletController._(core, wallet, chains);
    await controller._onInitController();
    return controller;
  }

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
