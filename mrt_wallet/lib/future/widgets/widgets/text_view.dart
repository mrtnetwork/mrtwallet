import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class APPTextView extends StatefulWidget {
  final String text;
  final String title;
  const APPTextView({required this.text, required this.title, super.key});

  @override
  State<APPTextView> createState() => _APPTextView();
}

class _APPTextView extends State<APPTextView> with SafeState {
  bool selectable = false;
  void toggeSelectable() {
    selectable = !selectable;
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(widget.title),
          actions: [
            CopyTextIcon(dataToCopy: widget.text),
            WidgetConstant.width8,
          ],
        ),
        const SliverPadding(padding: WidgetConstant.paddingVertical10),
        SliverPadding(
          padding: WidgetConstant.paddingHorizontal20,
          sliver: SliverToBoxAdapter(
            child: selectable
                ? SelectableText(
                    widget.text,
                    enableInteractiveSelection: true,
                  )
                : Text(widget.text),
          ),
        ),
        const SliverPadding(padding: WidgetConstant.paddingVertical20),
      ],
    );
  }
}
