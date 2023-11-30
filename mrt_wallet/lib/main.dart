import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mrt_native_support/models/platform.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/security_pages/backup_wallet.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/security_pages/security.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/setting/setting.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/setup_pages/setup.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
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
  AppMaterialController.restoreMaterial(materialData);
  runApp(Repository(child: const MyBTC()));
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
  const MyBTC({super.key});

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WalletProvider>(
      controller: () => WalletProvider(Repository.navigatorKey(context)),
      removable: false,
      stateId: StateIdsConst.main,
      builder: (m) {
        return MaterialApp(
          scaffoldMessengerKey: Repository.messengerKey(context),
          title: AppGlobalConst.name,
          scrollBehavior: AppScrollBehavior(PlatformInterface.appPlatform),
          builder: (context, child) {
            return ConstraintsBoxView(child: child!);
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
      case PagePathConst.bitcoinTransaction:
        return const SendBitcoinTransactionView();
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
      default:
        return const HomeScreen();
    }
  }

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
