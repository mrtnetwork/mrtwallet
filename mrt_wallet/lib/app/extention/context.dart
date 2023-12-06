import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';

extension QuickContextAccsess on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get hasFocus => FocusScope.of(this).hasFocus;
  bool get hasParentFocus => FocusScope.of(this).parent?.hasFocus ?? false;
  void mybePop() {
    if (mounted) Navigator.maybeOf(this);
  }

  void clearFocus() {
    if (mounted) {
      FocusScope.of(this).unfocus();
    }
  }

  Future<T?> to<T>(String path, {dynamic argruments}) async {
    if (mounted) {
      return Navigator.pushNamed<T>(this, path, arguments: argruments);
    }
    return null;
  }

  void showAlert(String message) {
    if (mounted) {
      final sc = Repository.messengerKey(this);
      SnackBar snackBar;
      snackBar = createSnackAlert(
        message: message,
        theme: theme,
        onTap: () {
          sc.currentState?.clearSnackBars();
        },
      );
      sc.currentState?.showSnackBar(snackBar);
    }
  }

  Future<T?> openSliverBottomSheet<T>(Widget child, String label,
      {double minExtent = 0.7,
      double maxExtend = 1,
      double? initialExtend,
      List<Widget> appbarActions = const []}) async {
    return await showModalBottomSheet<T>(
      context: this,
      builder: (context) => AppBottomSheet(
        label: label,
        actions: appbarActions,
        minExtent: minExtent,
        maxExtend: maxExtend,
        initiaalExtend: initialExtend,
        child: child,
      ),
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Future<T?> openSliverDialog<T>(
    Widget widget,
    String label,
  ) async {
    return await showAdaptiveDialog(
      context: this,
      useRootNavigator: false,
      builder: (context) {
        return DialogView(
          title: label,
          child: widget,
        );
      },
    );
  }

  void pop<T>([T? result]) {
    if (mounted) {
      Navigator.of(this).pop(result);
    }
  }

  T? getNullArgruments<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args == null) return null;
    if (args.runtimeType != T) {
      throw ArgumentError(
          "value of type ${args.runtimeType} is not subtype ${T.runtimeType}");
    }
    return args as T?;
  }

  T getArgruments<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args == null) {
      throw StateError("argruments not found");
    }

    return args as T;
  }

  dynamic getDynamicArgs() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args == null) {
      throw StateError("argruments not found");
    }

    return args;
  }

  void popToHome() {
    Navigator.of(this)
        .popUntil((route) => route.settings.name == PagePathConst.home);
  }

  BuildContext? get scaffoldContext =>
      Repository.scaffoldKey(this).currentContext;

  GlobalKey<NavigatorState> get navigatorKey => Repository.navigatorKey(this);
}
