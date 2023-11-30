import 'package:flutter/material.dart';

typedef DynamicVoid = void Function();
typedef StringVoid = void Function(String);
typedef NullStringString = String? Function(String?);
typedef NullStringT = String? Function<T>(T?);
typedef NullBoolVoid = void Function(bool?);
typedef FutureVoid = Future<void> Function();
typedef FutureT = Future<T?> Function<T>();
typedef VoidSetT = Function<T>(Set<T>);
typedef FuncBool = bool Function();

typedef FuncBoolString = bool Function(String);
typedef FuncFutureBoolString = Future<bool> Function(String);
typedef NullWidget = Widget? Function();
typedef FuncWidget = Widget? Function();
typedef IntVoid = Function(int);

typedef FuncVoidSize = Function(Size);

typedef FuncVoidNullT = void Function<T>(T?);

typedef FutureNullString = Future<String?> Function();
typedef FuncWidgetWithScroll = Widget Function(ScrollController);
