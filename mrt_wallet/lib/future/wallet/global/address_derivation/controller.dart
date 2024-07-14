import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show QuickContextAccsess, StateController, Translate;
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart'
    show WalletNetwork, ChainHandler, NetworkAccountCore, NewAccountParams;
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wroker/keys/models/encrypted_imported.dart';
import 'package:mrt_wallet/wroker/keys/models/seed.dart';

typedef OnGenerateDerivation = Future<Bip32AddressIndex?> Function();

enum AddressDerivationMode {
  hdWallet,
  importedKey;

  bool get isCustomKey => this == AddressDerivationMode.importedKey;
}

typedef OnSelectDerivation = void Function(
    AddressDerivationMode mode, EncryptedCustomKey? selectedKey);

class AddressDerivationController extends StateController {
  AddressDerivationController(
      {required this.wallet,
      required this.network,
      required this.chainAccount});
  final WalletProvider wallet;
  final GlobalKey visibleContinue =
      GlobalKey(debugLabel: "visibleGenerateAddress");
  final WalletNetwork network;

  bool showCustomKes = false;
  bool showSetupPage = false;

  final GlobalKey<PageProgressState> pageProgressKey =
      GlobalKey<PageProgressState>(debugLabel: "SetupEthereumAddressView");
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  final GlobalKey visibleGenerateAddress =
      GlobalKey(debugLabel: "visibleContinue");
  final GlobalKey visibleXAddressDetails =
      GlobalKey(debugLabel: "visibleContinue");

  final ChainHandler chainAccount;
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

  Future<AddressDerivationIndex?> getCoin(
      {required BuildContext context,
      required SeedTypes seedGeneration,
      List<CryptoCoins>? selectedCoins}) async {
    if (!(form.currentState?.validate() ?? true)) return null;
    if (selectedCoins != null) {
      if (selectedCoins.any((e) => !coins.contains(e))) {
        throw WalletExceptionConst.invalidCoin;
      }
    }
    final c = selectedCoins?.first ?? coin;
    final customKeys = wallet.getCustomKeysForCoin(selectedCoins ?? coins);
    return await context.openSliverBottomSheet<AddressDerivationIndex>(
        "setup_derivation".tr,
        child: SetupDerivationModeView(
          coin: c,
          chainAccout: chainAccount,
          customKeys: customKeys,
          networkCoins: selectedCoins ?? coins,
          seedGenerationType: seedGeneration,
        ));
  }

  void generateAddress(NewAccountParams newAccount) async {
    if (!(form.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("generating_new_addr".tr);
    final result = await wallet.deriveNewAccount(newAccount);
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.success(
          backToIdle: false,
          progressWidget: SuccessWithButtonView(
            buttonText: "generate_new_address".tr,
            buttonWidget: ContainerWithBorder(
                margin: WidgetConstant.paddingVertical8,
                child: AddressDetailsView(
                  address: result.result,
                )),
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
