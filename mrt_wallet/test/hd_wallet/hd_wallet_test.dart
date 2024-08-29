import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';
import 'package:mrt_wallet/wallet/web3/core/request/web_request.dart';

class TestWallet extends WalletCore {
  @override
  bool get useMemoryStorage => true;
  @override
  void onChange() {}

  @override
  void onChangeStatus(WalletPageStatus status, {String? message}) {}

  @override
  bool onWeb3Request(Web3Request request) {
    throw UnimplementedError();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformInterface.instance.getConfig();
  const mnemonic =
      "kiss dad garment soft that place balance resist hat uncle submit recall";
  final wallet = TestWallet();
  await wallet.initWallet(useIsolate: false);
  final initializeWallet = await wallet.createWallet(
      mnemonic: mnemonic, passphrase: null, password: "MyPassowrd##1234");
  await wallet.setup(
      hdWallet: initializeWallet,
      password: "MyPassowrd##1234",
      walletInfos: const WalletUpdateInfosData(
          name: "MyWallet",
          lockTime: WalletLockTime.fiveMinute,
          requirmentPassword: false,
          asDefaultWallet: true,
          protectWallet: false));
  wallet.getChains();
}
