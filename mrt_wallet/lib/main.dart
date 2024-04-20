import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mrt_native_support/models/platform.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_cash_pages/transaction/transaction/send_transaction.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/update_provider/import_electrum_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/setup_address_page.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/pages/build_transaction.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cosmos/setup_address.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cosmos/transaction/fields/transfer.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/import_network/edit_network.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/import_network/import_network.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/setup_address.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/token/import_tokens.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/transaction/fields/ethereum_transfer_field_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/setup_address.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/setup_multi_sig_address.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/token/import_nfts.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/token/import_token.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/fields/ripple_tranaction_fields_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/fields/transfer.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/solana_pages/setup_address.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/solana_pages/spl_token/account_spl_tokens_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/solana_pages/transaction/fields/transfer.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/setup_address.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/setup_multisig_address.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/token/import_trc10_tokens.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/fields/tron_transaction_fields.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/fields/tron_transfer_field_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/token/import_token.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/security_pages/security.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/setting/setting.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/setup_pages/setup.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/app/app_seting.dart';
import 'package:mrt_wallet/models/app/material.dart';

import 'future/pages/wallet_pages/account_pages/account_pages.dart';
import 'future/pages/wallet_pages/network/bitcoin_pages/bitcoin.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  runZonedGuarded(run, (error, stack) {
    WalletLogging.print("zone error $error $stack");
  });
}

void run() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformInterface.appPlatform == AppPlatform.windows) {
    await PlatformInterface.interface.window.init();
    await PlatformInterface.interface.window.waitUntilReadyToShow();
    await PlatformInterface.interface.window
        .setBounds(null, size: const Size(500, 700));
    await PlatformInterface.interface.window.setResizable(false);
  }
  final materialData = await PlatformInterface.interface
      .readSecure(StorageKeysConst.appMaterial);
  final setting = AppSetting.fromHex(materialData);
  AppMaterialController.fromAppSetting(setting);
  runApp(Repository(child: MyBTC(setting: setting)));
}

class Repository<T extends StateController> extends InheritedWidget {
  Repository({super.key, required super.child});
  final RepositoryController r = RepositoryController();

  static T? stateOf<T extends StateController>(
      BuildContext context, String stateId) {
    final re = context.dependOnInheritedWidgetOfExactType<Repository>();
    return re?.r.getState<T>(stateId)!;
  }

  static RepositoryController of(BuildContext context) {
    final re = context.dependOnInheritedWidgetOfExactType<Repository>();
    return re!.r;
  }

  static GlobalKey<ScaffoldState> scaffoldKey(BuildContext context) {
    final re = context.dependOnInheritedWidgetOfExactType<Repository>();
    return re!.r.scaffoldKey;
  }

  static GlobalKey<ScaffoldMessengerState> messengerKey(BuildContext context) {
    final re = context.dependOnInheritedWidgetOfExactType<Repository>();
    return re!.r.messengerKey;
  }

  static GlobalKey<NavigatorState> navigatorKey(BuildContext context) {
    final re = context.dependOnInheritedWidgetOfExactType<Repository>();
    return re!.r.navigatorKey;
  }

  static PageRouter pageRouter(BuildContext context) {
    final re = context.dependOnInheritedWidgetOfExactType<Repository>();
    return re!.r.pageRoute;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget != this;
  }
}

extension Watch on BuildContext {
  T watch<T extends StateController>(String stateId) {
    return Repository.stateOf(this, stateId)!;
  }
}

class MyBTC extends StatelessWidget {
  const MyBTC({super.key, required this.setting});
  final AppSetting setting;

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WalletProvider>(
      controller: () =>
          WalletProvider(Repository.navigatorKey(context), setting),
      removable: false,
      stateId: StateIdsConst.main,
      builder: (m) {
        return MaterialApp(
          scaffoldMessengerKey: Repository.messengerKey(context),
          title: AppGlobalConst.name,
          scrollBehavior: AppScrollBehavior(PlatformInterface.appPlatform),
          builder: (context, child) {
            if (PlatformInterface.isWindows || PlatformInterface.isWeb) {
              return ConstraintsBoxView(child: child!);
            }
            return child!;
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppMaterialController.appTheme,
          locale: AppMaterialController.locale,
          onGenerateRoute: Repository.pageRouter(context).onGenerateRoute,
          initialRoute: PagePathConst.home,
          navigatorObservers: [MyRouteObserver()],
          showSemanticsDebugger: false,
          color: AppMaterialController.appTheme.colorScheme.primary,
          darkTheme: AppMaterialController.appTheme,
          navigatorKey: Repository.navigatorKey(context),
        );
      },
    );
  }
}

class PageRouter {
  static Widget _page(String? name) {
    switch (name) {
      case PagePathConst.setup:
        return const SetupWallet();
      case PagePathConst.solanaTransfer:
        return const SolanaTransferTransactionView();
      case PagePathConst.bitcoinTransaction:
        return const SendBitcoinTransactionView();
      case PagePathConst.bitcoinCashTransaction:
        return const SendBitcoinCashTransactionView();
      case PagePathConst.setupBitcoinMultsig:
        return const SetupBitcoinMultiSigAddressView();
      case PagePathConst.setupBitcoinAddress:
        return const SetupBitcoinAddressView();
      case PagePathConst.exportSeed:
        return const ExportSeedView();
      case PagePathConst.changePassword:
        return const ChangeWalletPasswordView();
      case PagePathConst.eraswWallet:
        return const EraseWalletView();
      case PagePathConst.exportPrivateKey:
        return const AccountPrivteKeyView();
      case PagePathConst.removeAccount:
        return const DeleteAccountView();
      case PagePathConst.importAccount:
        return const ImportAccountView();
      case PagePathConst.setting:
        return const AppSettingView();
      case PagePathConst.updateSetting:
        return const UpdateWalletSettingView();
      case PagePathConst.backupWallet:
        return const BackupWalletView();
      case PagePathConst.manageImportedKey:
        return const ManageImportedKeysView();
      case PagePathConst.setupRippleAddress:
        return const SetupRippleAddressView();
      case PagePathConst.setupEthAddress:
        return const SetupEthereumAddressView();
      case PagePathConst.setupTronAddress:
        return const SetupTronAddressView();
      case PagePathConst.rippleTransfer:
        return const RippleTransferTransactionView();
      case PagePathConst.ethereumTransaction:
        return const EthereumTransferTransactionView();
      case PagePathConst.tronTransfer:
        return const TronTransferTransactionView();
      case PagePathConst.rippleAddToken:
        return const MonitorRippleTokenView();
      case PagePathConst.rippleAddNfts:
        return const MonitorRippleNFTsView();
      case PagePathConst.rippleTransaction:
        return const RippleTransactionFieldsView();
      case PagePathConst.rippleMultisigAddress:
        return const SetupRippleMutlisigAddressView();
      case PagePathConst.importERC20Token:
        return const ImportERC20TokenView();
      case PagePathConst.importTRC20Token:
        return const ImportTRC20TokenView();
      case PagePathConst.importTrc10Token:
        return const MonitorTronTRC10TokenView();
      case PagePathConst.tronMultiSigAddress:
        return const SetupTronMultiSigAddressView();
      case PagePathConst.tronTransaction:
        return const TronTransactionFieldsView();
      case PagePathConst.importEVMNetwork:
        return const ImportEVMNetwork();
      case PagePathConst.editEvmNetwork:
        return const EditEVMNetwork();
      case PagePathConst.updateElectrumProviders:
        return const ImportElectrumProviderView();
      case PagePathConst.setupSolanaAddress:
        return const SetupSolanaAddressView();
      case PagePathConst.importSPLTokens:
        return const SolanaImportSPLTokensView();
      case PagePathConst.setupCardanoAddress:
        return const SetupCardanoAddressView();
      case PagePathConst.cardanoTransaction:
        return const SendCardanoTransactionView();
      case PagePathConst.setupCosmosAddress:
        return const SetupCosmosAddressView();
      case PagePathConst.cosmosTransaction:
        return const CosmosTransferTransactionView();
      default:
        return const HomeScreen();
    }
  }

  /// SetupCosmosAddressView

  /// SendCardanoTransactionView
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return MaterialPageView(child: _page(settings.name));
      },
      transitionDuration: AppGlobalConst.milliseconds100,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      settings: settings,
      allowSnapshotting: false,
      fullscreenDialog: false,
    );
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
