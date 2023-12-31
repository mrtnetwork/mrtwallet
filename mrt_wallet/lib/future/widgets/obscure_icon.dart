import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/types/typedef.dart';

class ObscureIcon extends StatelessWidget {
  const ObscureIcon({required this.show, required this.onTap, super.key});
  final bool show;
  final DynamicVoid onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: AnimatedSwitcher(
          duration: AppGlobalConst.animationDuraion,
          child: show
              ? const Icon(Icons.password, key: ValueKey<bool>(false))
              : const Icon(Icons.remove_red_eye, key: ValueKey<bool>(true)),
        ),
      ),
    );
  }
}
