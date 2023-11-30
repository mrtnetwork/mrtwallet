part of 'package:mrt_wallet/app/state_managment/state_managment.dart';

class RepositoryController {
  final Map<String, StateController> _state = {};
  void _add<T extends StateController>(
      BuildContext context, T stateController) {
    _state.addAll({stateController.repositoryId: stateController});
  }

  void _remove(String repositoryId) {
    _state.remove(repositoryId);
  }

  T? getState<T extends StateController>(String? repositoryId) =>
      _state[repositoryId] as T?;
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "Repository");
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>(debugLabel: "Repository_1");
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "Repository_2");
  final pageRoute = PageRouter();
}
