part of 'package:mrt_wallet/future/state_managment/state_managment.dart';

class RepositoryController {
  final Map<String, StateController> _state = {};
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "Repository");
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>(debugLabel: "Repository_1");
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "Repository_2");
  void _add<T extends StateController>(
      BuildContext context, String repositoryId, T stateController) {
    if (_state.containsKey(repositoryId)) return;
    _state.addAll({repositoryId: stateController});
  }

  void _remove(String repositoryId) {
    final r = _state.remove(repositoryId);
    r?._close();
  }

  T? getState<T extends StateController>(String? repositoryId) =>
      _state[repositoryId] as T?;

  T getOrCreate<T extends StateController>(
      String repositoryId, T Function() controller) {
    _state[repositoryId] ??= controller();
    return _state[repositoryId] as T;
  }
}
