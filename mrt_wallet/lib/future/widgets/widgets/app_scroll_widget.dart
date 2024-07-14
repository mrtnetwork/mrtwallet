import 'package:flutter/material.dart';

class AccountTabbarScrollWidget extends StatelessWidget {
  const AccountTabbarScrollWidget({required this.slivers, Key? key})
      : super(key: key);
  final List<Widget> slivers;
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context)
          .copyWith(scrollbars: false, physics: const ClampingScrollPhysics()),
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          ...slivers
        ],
      ),
    );
  }
}
