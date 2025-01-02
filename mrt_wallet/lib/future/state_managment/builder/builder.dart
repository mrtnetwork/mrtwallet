part of 'package:mrt_wallet/future/state_managment/state_managment.dart';

typedef StateBulder<T extends StateController> = Widget Function(T controller);
typedef ControllerBuilder<T extends StateController> = T Function();

class MrtViewBuilder<T extends StateController> extends StatefulWidget {
  final StateBulder<T> builder;
  final ControllerBuilder<T> controller;
  final String? stateId;
  final bool removable;
  final List<String> onRemoveIds;
  final String repositoryId;

  const MrtViewBuilder({
    super.key,
    required this.controller,
    required this.builder,
    required this.repositoryId,
    this.onRemoveIds = const [],
    this.stateId,
    this.removable = true,
  });

  @override
  MrtViewBuilderState<T> createState() => MrtViewBuilderState<T>();
}

class MrtViewBuilderState<T extends StateController>
    extends State<MrtViewBuilder<T>> with SafeState {
  late final T stateController = widget.controller();
  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    stateController._start();
    stateController.addListener(widget.stateId, update);
  }

  @override
  void dispose() {
    super.dispose();
    stateController.removeListener(widget.stateId, update);
    if (widget.removable) {
      r._remove(widget.repositoryId);
      for (final i in widget.onRemoveIds) {
        r._remove(i);
      }
    }
  }

  late RepositoryController r;

  @override
  void didChangeDependencies() {
    r = StateRepository.of(context);
    r._add(context, widget.repositoryId, stateController);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MrtViewBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(stateController);
  }
}
