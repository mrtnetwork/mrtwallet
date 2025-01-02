import 'package:flutter/material.dart';

class APPAnimatedRemovableList extends StatefulWidget {
  const APPAnimatedRemovableList(
      {required this.itemBuilder,
      required this.length,
      required this.shrinkWrap,
      this.physics,
      super.key});
  final int length;
  final bool shrinkWrap;
  final Widget Function(BuildContext, int index, Animation<double>,
      [bool? inRemove]) itemBuilder;
  final ScrollPhysics? physics;
  @override
  State<APPAnimatedRemovableList> createState() => APPRemovableListState();
}

class APPRemovableListState extends State<APPAnimatedRemovableList> {
  final GlobalKey<AnimatedListState> key = GlobalKey();
  void removeIndex(int index) {
    Widget builder(context, animation) {
      // A method to build the Card widget.
      return widget.itemBuilder(context, index, animation, true);
    }

    key.currentState?.removeItem(index, builder);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: key,
      itemBuilder: widget.itemBuilder,
      initialItemCount: widget.length,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
    );
  }
}
