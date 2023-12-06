import 'package:blockchain_utils/bip/bip/bip39/bip39.dart';
import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/compare/compare.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/keys/wallet_backup.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum SetupWalletPage {
  password,
  mnemonic,
  confirm,
  extraOption,
  enterMnemonic,
  backup
}

enum SetupWalletMode { generate, exist, backup }

class SetupWalletController extends StateController {
  SetupWalletController(this.setupMode);
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final SetupWalletMode setupMode;
  Mnemonic? _mnemonic;
  Mnemonic? get mnemonic => _mnemonic;
  int _mnemoicWord = 12;
  int get mnemonicWord => _mnemoicWord;

  Bip39Languages _language = Bip39Languages.english;
  Bip39Languages get language => _language;

  SetupWalletPage _page = SetupWalletPage.password;
  SetupWalletPage get page => _page;
  bool get inPassword => _page == SetupWalletPage.password;
  bool get inMnemonic => _page == SetupWalletPage.mnemonic;
  bool get inConfirm => _page == SetupWalletPage.confirm;
  bool get inExtraOption => _page == SetupWalletPage.extraOption;

  void backButton() {
    switch (page) {
      case SetupWalletPage.extraOption:
        _page = SetupWalletPage.confirm;
        break;
      case SetupWalletPage.confirm:
        _page = SetupWalletPage.mnemonic;
        _mnemonic = null;
        break;
      case SetupWalletPage.mnemonic:
      case SetupWalletPage.enterMnemonic:
        _page = SetupWalletPage.password;
        break;
      default:
        break;
    }
    notify();
  }

  String _password = "";

  void setPassword(String password) {
    if (AppStringUtility.isStrongPassword(password)) {
      _password = password;
      if (setupMode == SetupWalletMode.exist) {
        _page = SetupWalletPage.enterMnemonic;
      } else if (setupMode == SetupWalletMode.backup) {
        _page = SetupWalletPage.backup;
      } else {
        _page = SetupWalletPage.mnemonic;
      }
      notify();
    }
  }

  void updateMnemonicCount(int? value) {
    if (value == null) return;
    _mnemoicWord = value;
    _mnemonic = null;
    notify();
  }

  void updateLanguage(Bip39Languages? language) {
    if (language == null) return;
    _language = language;
    _mnemonic = null;
    notify();
  }

  void generate() {
    final wNum = Bip39WordsNum.values
        .firstWhere((element) => element.value == _mnemoicWord);
    final mne = Bip39MnemonicGenerator(language);
    _mnemonic = mne.fromWordsNumber(wNum);
    notify();
  }

  void toConfirm() {
    if (_mnemonic == null) return;
    _page = SetupWalletPage.confirm;
    notify();
  }

  void toExtra(List<String> selectedMnemonic) {
    if (!iterableIsEqual(selectedMnemonic, _mnemonic?.toList())) {
      return;
    }
    _page = SetupWalletPage.extraOption;
    notify();
  }

  Future<(WalletMasterKeys, String)> setup(String? passphrase,
      {Mnemonic? exitingMnemonic}) async {
    if (passphrase?.isEmpty ?? false) {
      throw WalletExceptionConst.invalidMnemonicPassphrase;
    }
    final generate = await WalletMasterKeys.setup(
        exitingMnemonic?.toStr() ?? mnemonic!.toStr(), passphrase ?? "");
    return (generate, _password);
  }

  Future<String> setupBackup(WalletBackup backup,
      {Mnemonic? exitingMnemonic}) async {
    if (!AppStringUtility.isStrongPassword(_password)) {
      throw WalletExceptionConst.incorrectPassword;
    }

    return _password;
  }

  @override
  String get repositoryId => "setup_wallet";

  @override
  void close() {
    PlatformInterface.interface.secureFlag(isSecure: false);
  }

  @override
  void init() {
    PlatformInterface.interface.secureFlag(isSecure: true);
    super.init();
  }
}
