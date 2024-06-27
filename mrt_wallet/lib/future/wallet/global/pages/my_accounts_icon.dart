import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';

class MyAccountIcon extends StatelessWidget {
  const MyAccountIcon({super.key, required this.onTap});
  final DynamicVoid onTap;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.account_box_sharp),
    );
  }
}
