import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

typedef OnFutureData<T> = Widget Function(T);

class APPFutureBuilder<T> extends StatelessWidget {
  const APPFutureBuilder({required this.onData, required this.future, Key? key})
      : super(key: key);
  final Future<T> future;
  final OnFutureData<T> onData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return onData(snapshot.data as T);
        }
        return CircleAssetsImgaeView(APPConst.logo);
      },
    );
  }
}

class APPFutureBuilder2 extends StatelessWidget {
  const APPFutureBuilder2({required this.onData, Key? key}) : super(key: key);
  final Future<WidgetContext> onData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: onData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!(context);
        }
        return CircleAssetsImgaeView(APPConst.logo);
      },
    );
  }
}
