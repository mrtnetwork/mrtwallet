import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mrt_native_support/models/size/models/size.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

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
    WalletLogging.log("zone error: $error $stack");
  });
}

void run() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformInterface.appPlatform.isDesktop) {
    await PlatformInterface.instance.desktop.init();
    await PlatformInterface.instance.desktop.waitUntilReadyToShow();
    await PlatformInterface.instance.desktop.setMaximumSize(const WidgetSize(
        width: APPConst.desktopAppWidth, height: APPConst.desktopAppHeight));
  }
  final config = await PlatformInterface.instance.getConfig();
  final materialData =
      await PlatformInterface.instance.readSecure(StorageConst.setting);
  final setting = APPSetting.fromHex(materialData, config);
  ThemeController.fromAppSetting(setting);
  runApp(StateRepository(child: MyBTC(setting: setting)));
}

class MyBTC extends StatelessWidget {
  const MyBTC({super.key, required this.setting});
  final APPSetting setting;

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WalletProvider>(
      controller: () =>
          WalletProvider(StateRepository.navigatorKey(context), setting),
      removable: false,
      stateId: StateConst.main,
      repositoryId: StateConst.main,
      builder: (m) {
        return MaterialApp(
          scaffoldMessengerKey: StateRepository.messengerKey(context),
          title: APPConst.name,
          scrollBehavior: AppScrollBehavior(PlatformInterface.appPlatform),
          builder: (context, child) {
            double? maxWidth;
            if (PlatformInterface.appPlatform.isDesktop) {
              maxWidth = APPConst.desktopAppWidth;
            } else if (PlatformInterface.isWeb) {
              maxWidth = APPConst.maxViewWidth;
            }
            return MediaQuery(
              data: context.mediaQuery.copyWith(
                  textScaler:
                      context.mediaQuery.textScaler.clamp(maxScaleFactor: 1.4)),
              child: maxWidth == null
                  ? child!
                  : ConstraintsBoxView(maxWidth: maxWidth, child: child!),
            );
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeController.appTheme,
          locale: ThemeController.locale,
          onGenerateRoute: PageRouter.onGenerateRoute,
          initialRoute: PageRouter.home,
          navigatorObservers: [MyRouteObserver()],
          showSemanticsDebugger: false,
          debugShowCheckedModeBanner: false,
          color: ThemeController.appTheme.colorScheme.primary,
          darkTheme: ThemeController.appTheme,
          navigatorKey: StateRepository.navigatorKey(context),
        );
      },
    );
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
