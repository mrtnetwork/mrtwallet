part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

typedef OnUpdateWallet = Future<void> Function(HDWallet, bool?);

abstract class _WalletController
    with WalletStorageWriter, WalletStorageManger2, WalletNetworkManager2 {
  @override
  HDWallet _wallet;
  _WalletController(this._wallet, this._onUpdateWallet);
  final OnUpdateWallet _onUpdateWallet;
}

class WalletController extends _WalletController
    with WalletManager2, BaseRepository {
  WalletController._(HDWallet wallet, OnUpdateWallet onUpdateWallet)
      : super(wallet, onUpdateWallet);

  static Future<WalletController> _setup(
      HDWallet wallet, OnUpdateWallet onUpdateWallet) async {
    final controller = WalletController._(wallet, onUpdateWallet);
    await controller._setupNetwork();
    controller._streamBalances();
    return controller;
  }

  @override
  Future<void> _updateWallet(HDWallet wallet, bool? asDefaultWallet) async {
    if (wallet._checksum != _wallet._checksum) {
      throw WalletExceptionConst.incorrectWalletData;
    }
    _wallet = wallet;
    await _onUpdateWallet(wallet, asDefaultWallet);
  }
}
