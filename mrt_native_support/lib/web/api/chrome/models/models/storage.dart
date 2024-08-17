class StorageEventListener {
  final String key;
  final String? newValue;
  final String? oldValue;
  bool get updated => newValue != null;
  bool get removed => oldValue != null;
  const StorageEventListener(this.key,
      {required this.newValue, required this.oldValue});
}
