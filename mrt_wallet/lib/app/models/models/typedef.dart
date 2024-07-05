import 'package:flutter/material.dart';

typedef DynamicVoid = void Function();
typedef StringVoid = void Function(String);
typedef NullStringString = String? Function(String?);
typedef NullStringT<T> = String? Function(T?);
typedef NullBoolVoid = void Function(bool?);
typedef FutureVoid = Future<void> Function();
typedef FutureT<T> = Future<T> Function();
typedef VoidSetT<T> = Function(Set<T>);
typedef FuncBool<T> = bool Function(T);

typedef FuncBoolString = bool Function(String);
typedef FuncFutureBoolString = Future<bool> Function(String);
typedef NullWidget = Widget? Function();
typedef FuncWidget = Widget Function();
typedef FuncWidgetContext = Widget Function(BuildContext context);

typedef IntVoid = Function(int);

typedef FuncVoidSize = Function(Size);

typedef FuncVoidNullT<T> = void Function(T);

typedef FutureNullString = Future<String?> Function();
typedef FuncWidgetWithScroll = Widget Function(ScrollController);

typedef WidgetContext = Widget Function(BuildContext);

typedef FuncTResult<T> = T? Function(T?);
