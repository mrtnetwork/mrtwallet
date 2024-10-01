import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/router/page_router.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

extension CustomColorsSchame on ColorScheme {
  Color get disable => onSurface.withOpacity(0.38);
  Color get orange => Colors.orange;
  Color get green => Colors.green;
  Color get transparent => Colors.transparent;
}

extension QuickColor on Color {
  TextStyle? titleLarge(BuildContext context) {
    return context.textTheme.titleLarge?.copyWith(color: this);
  }

  TextStyle? titleMedium(BuildContext context) {
    return context.textTheme.titleMedium?.copyWith(color: this);
  }

  TextStyle? bodyMedium(BuildContext context) {
    return context.textTheme.bodyMedium?.copyWith(color: this);
  }

  TextStyle? bodySmall(BuildContext context) {
    return context.textTheme.bodySmall?.copyWith(color: this);
  }

  TextStyle? lableLarge(BuildContext context) {
    return context.textTheme.labelLarge?.copyWith(color: this);
  }

  Color get opacity5 {
    return withOpacity(0.5);
  }

  Color get opacity1 {
    return withOpacity(0.1);
  }
}

extension QuickContextAccsess on BuildContext {
  T watch<T extends StateController>(String stateId) {
    return StateRepository.stateOf(this, stateId)!;
  }

  T watchOrCreate<T extends StateController>(
      {required String stateId, required T Function() controller}) {
    return StateRepository.stateOfCreate(this, stateId, controller)!;
  }

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
      final push = await Navigator.pushNamed(this, path, arguments: argruments);
      return (push as T?);
    }
    return null;
  }

  bool toSync(String path, {dynamic argruments}) {
    if (!mounted) return false;
    Navigator.pushNamed(this, path, arguments: argruments);
    return true;
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
      final sc = StateRepository.messengerKey(this);
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
      List<Widget> Function(BuildContext context)? appbarActions,
      List<Widget> slivers = const [],
      bool centerContent = true}) async {
    if (!mounted) return null;
    return await showModalBottomSheet<T>(
      context: this,
      constraints: const BoxConstraints(maxWidth: 900),
      builder: (context) => AppBottomSheet(
        label: label,
        body: bodyBuilder,
        actions: appbarActions?.call(context) ?? [],
        minExtent: minExtent,
        maxExtend: maxExtend,
        centerContent: centerContent,
        slivers: slivers,
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
        .popUntil((route) => route.settings.name == PageRouter.home);
  }

  BuildContext? get scaffoldContext =>
      StateRepository.scaffoldKey(this).currentContext;

  GlobalKey<ScaffoldState> get scaffoldKey => StateRepository.scaffoldKey(this);

  GlobalKey<NavigatorState> get navigatorKey =>
      StateRepository.navigatorKey(this);
  ModalRoute? route() {
    return ModalRoute.of(this);
  }

  String? path() {
    String? currentPath;
    navigatorKey.currentState?.popUntil((route) {
      currentPath = route.settings.name;
      return true;
    });
    return currentPath;
  }
}
