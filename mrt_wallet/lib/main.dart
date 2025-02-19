import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/models/size/models/size.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

void main() async {
  WalletLogging.error("state1d");
  runZonedGuarded(_runApplication, (error, stack) {
    // WalletLogging.log("zoon error: $error");
    WalletLogging.error("got error here ?! $error");
  });
}

class APPHTTPConfig extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _configDesktop(APPSetting setting) async {
  if (!PlatformInterface.appPlatform.isDesktop) return;
  await PlatformInterface.instance.desktop.init();
  await PlatformInterface.instance.desktop.waitUntilReadyToShow();
  await PlatformInterface.instance.desktop.setMaximumSize(const WidgetSize(
      width: APPConst.desktopAppWidth, height: APPConst.desktopAppHeight));
  if (setting.size?.devicePixelRatio != null) {
    final size = setting.size!;
    await PlatformInterface.instance.desktop
        .setBounds(pixelRatio: size.devicePixelRatio!, bounds: size);
  }
}

Future<APPSetting> _readSetting() async {
  final config = await PlatformInterface.instance.getConfig();
  final materialData =
      await PlatformInterface.instance.readSecure(StorageConst.setting);
  return APPSetting.fromHex(materialData, config);
}

Future<void> _runApplication() async {
  HttpOverrides.global = APPHTTPConfig();
  WidgetsFlutterBinding.ensureInitialized();
  final setting = await _readSetting();
  await _configDesktop(setting);
  ThemeController.fromAppSetting(setting);
  runApp(StateRepository(child: MyBTC(setting: setting)));
}

class MyBTC extends StatelessWidget {
  const MyBTC({super.key, required this.setting});
  final APPSetting setting;

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WalletProvider>(
      controller: () => WalletProvider(
          appSetting: setting,
          navigatorKey: StateRepository.navigatorKey(context)),
      removable: false,
      stateId: StateConst.main,
      repositoryId: StateConst.main,
      builder: (m) {
        WalletLogging.log("is update222d!");
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
              ThemeController.updatePrimary(context.theme);
              return MediaQuery(
                  data: context.mediaQuery.copyWith(
                      textScaler: context.mediaQuery.textScaler
                          .clamp(maxScaleFactor: 1.4)),
                  child: maxWidth == null
                      ? child!
                      : ConstraintsBoxView(maxWidth: maxWidth, child: child!));
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeController.appTheme,
            darkTheme: ThemeController.appTheme,
            locale: ThemeController.locale,
            onGenerateRoute: PageRouter.onGenerateRoute,
            initialRoute: PageRouter.home,
            navigatorObservers: [MyRouteObserver()],
            showSemanticsDebugger: false,
            debugShowCheckedModeBanner: false,
            color: ThemeController.appTheme.colorScheme.primary,
            navigatorKey: StateRepository.navigatorKey(context));
      },
    );
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
