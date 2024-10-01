typedef DynamicVoid = void Function();

typedef ObjectVoid = void Function(Object?);
typedef StringVoid = void Function(String);

typedef NullStringString = String? Function(String?);
typedef NullStringT<T> = String? Function(T?);
typedef NullBoolVoid = void Function(bool?);
typedef BoolVoid = void Function(bool);

typedef FutureVoid = Future<void> Function();
typedef FutureT<T> = Future<T> Function();
typedef VoidSetT<T> = Function(Set<T>);
typedef FuncBool<T> = bool Function(T);

typedef FuncBoolString = bool Function(String);
typedef FuncFutureBoolString = Future<bool> Function(String);
typedef FuncFutureNullableBoold = Future<bool?> Function();
typedef IntVoid = void Function(int);
typedef BigIntVoid = void Function(BigInt);

typedef FuncVoidNullT<T> = void Function(T);

typedef FutureNullString = Future<String?> Function();

typedef FuncTResult<T> = T? Function(T?);
