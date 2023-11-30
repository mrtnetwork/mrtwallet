part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

typedef SetupMnemonicCallBack = void Function(
    WalletMasterKeys mnemonic, String walletPassword);

enum WalletStatus { setup, lock, unlock }
