import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_derivation/setup_address_derivation_mode.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

typedef OnGenerateDerivation = Future<Bip32AddressIndex?> Function();

enum AddressDerivationMode {
  hdWallet,
  importedKey;

  bool get isCustomKey => this == AddressDerivationMode.importedKey;
}

typedef OnSelectDerivation = void Function(
    AddressDerivationMode mode, EncryptedCustomKey? selectedKey);

class AddressDerivationController extends StateController {
  AddressDerivationController({
    required this.wallet,
    required this.network,
    required this.chainAccount,
  });
  final WalletProvider wallet;
  final GlobalKey visibleContinue =
      GlobalKey(debugLabel: "visibleGenerateAddress");
  final AppNetworkImpl network;

  bool showCustomKes = false;
  bool showSetupPage = false;

  final GlobalKey<PageProgressState> pageProgressKey =
      GlobalKey<PageProgressState>(debugLabel: "SetupEthereumAddressView");
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  final GlobalKey visibleGenerateAddress =
      GlobalKey(debugLabel: "visibleContinue");
  final GlobalKey visibleXAddressDetails =
      GlobalKey(debugLabel: "visibleContinue");

  final AppChain chainAccount;
  NetworkAccountCore get networkAccounts => chainAccount.account;
  List<CryptoCoins> get coins => network.coins;
  CryptoCoins get coin => coins.first;

  Bip32AddressIndex? customKeyIndex;
  bool get derivationStandard => customKeyIndex == null;

  bool inited = false;

  void onChangeDerivation(OnGenerateDerivation onGenerateDerivation) async {
    if (derivationStandard) {
      customKeyIndex = await onGenerateDerivation();
    } else {
      customKeyIndex = null;
    }
    notify();
  }

  AddressDerivationIndex get nextDerivation {
    return chainAccount.account.nextDerive(coin);
  }

  Future<Bip32AddressIndex?> getCoin(BuildContext context) async {
    if (!(form.currentState?.validate() ?? true)) return null;
    final customKeys = wallet.getCustomKeysForCoin(coins);
    return await context.openSliverBottomSheet<Bip32AddressIndex>(
        "setup_derivation".tr,
        child: SetupDerivationModeView(
            coin: coin, chainAccout: chainAccount, customKeys: customKeys));
  }

  void generateAddress(NewAccountParams newAccount) async {
    if (!(form.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("generating_new_addr".tr);
    final result = await MethodCaller.call(() async {
      final result = await wallet.deriveNewAccount(newAccount);
      result.rethrowIfError();
      return result.result;
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.success(
          backToIdle: false,
          progressWidget: SuccessWithButtomView(
            buttomText: "generate_new_address".tr,
            buttomWidget: ContainerWithBorder(
                margin: WidgetConstant.paddingVertical8,
                child: AddressDetailsView(address: result.result)),
            onPressed: () {
              pageProgressKey.backToIdle();
            },
            text: "address_added_success".tr,
          ));
    }
    notify();
  }

  @override
  String get repositoryId => "address_derivation";
}
