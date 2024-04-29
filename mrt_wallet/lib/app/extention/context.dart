import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/types/typedef.dart';

extension CustomColorsSchame on ColorScheme {
  Color get disable => onSurface.withOpacity(0.38);
  Color get orange => Colors.orange;
  Color get green => Colors.green;
  Color get transparent => Colors.transparent;
}

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

  Future<T?> offTo<T>(String path, {dynamic argruments}) async {
    if (mounted) {
      final push =
          Navigator.popAndPushNamed<T, T>(this, path, arguments: argruments);
      return push;
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

  Future<T?> openSliverBottomSheet<T>(String label,
      {double minExtent = 0.7,
      double maxExtend = 1,
      Widget? child,
      double? initialExtend,
      BodyBuilder? bodyBuilder,
      List<Widget> appbarActions = const [],
      bool centerContent = true}) async {
    if (!mounted) return null;
    return await showModalBottomSheet<T>(
      context: this,
      constraints: const BoxConstraints(maxWidth: 900),
      builder: (context) => AppBottomSheet(
        label: label,
        body: bodyBuilder,
        actions: appbarActions,
        minExtent: minExtent,
        maxExtend: maxExtend,
        centerContent: centerContent,
        initiaalExtend: initialExtend,
        child: child,
      ),
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Future<T?> openSliverDialog<T>(WidgetContext widget, String label,
      {List<Widget> Function(BuildContext)? content}) async {
    return await showAdaptiveDialog(
      context: this,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) {
        return DialogView(
          title: label,
          content: content?.call(context) ?? const [],
          widget: widget(context),
        );
      },
    );
  }

  Future<T?> openDialogPage<T>(
    String label, {
    WidgetContext? child,
    List<Widget> Function(BuildContext)? content,
    Widget? fullWidget,
  }) async {
    return await showAdaptiveDialog(
      context: this,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) {
        return fullWidget ??
            DialogView(
                title: label,
                content: content?.call(context) ?? const [],
                child: child?.call(context) ?? WidgetConstant.sizedBox);
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
      return null;
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
