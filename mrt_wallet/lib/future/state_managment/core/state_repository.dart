part of 'package:mrt_wallet/future/state_managment/state_managment.dart';

class StateRepository<T extends StateController> extends InheritedWidget {
  StateRepository({super.key, required super.child});
  final RepositoryController controller = RepositoryController();

  static T? stateOf<T extends StateController>(
      BuildContext context, String stateId) {
    final repository =
        context.dependOnInheritedWidgetOfExactType<StateRepository>();
    return repository?.controller.getState<T>(stateId)!;
  }

  static T? stateOfCreate<T extends StateController>(
      BuildContext context, String stateId, T Function() controller) {
    final repository =
        context.dependOnInheritedWidgetOfExactType<StateRepository>();
    return repository?.controller.getOrCreate<T>(stateId, controller);
  }

  static RepositoryController of(BuildContext context) {
    final repository =
        context.dependOnInheritedWidgetOfExactType<StateRepository>();
    return repository!.controller;
  }

  static GlobalKey<ScaffoldState> scaffoldKey(BuildContext context) {
    final repository =
        context.dependOnInheritedWidgetOfExactType<StateRepository>();
    return repository!.controller.scaffoldKey;
  }

  static GlobalKey<ScaffoldMessengerState> messengerKey(BuildContext context) {
    final repository =
        context.dependOnInheritedWidgetOfExactType<StateRepository>();
    return repository!.controller.messengerKey;
  }

  static GlobalKey<NavigatorState> navigatorKey(BuildContext context) {
    final repository =
        context.dependOnInheritedWidgetOfExactType<StateRepository>();
    return repository!.controller.navigatorKey;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget != this;
  }
}
